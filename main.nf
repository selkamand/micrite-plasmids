#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params {
    // Sample sheet (csv) with three named columsn: sample, r1, r2 describing sampleids
    input: Path

    // Path to bakta database directory
    bakta_database: Path

    // Output directory name
    outdir: Path = "micrite_plasmid"
}

include { PLASMID_SPADES } from './modules/local/plasmidspades.nf'
include { BAKTA } from './modules/local/bakta.nf'
workflow {

    main:

    // Parse Sample Sheet
    ch_samples = channel.fromPath(params.input)
        .splitCsv(header: true)
        .map { row ->
            // Pull required columns out of the row
            def sample = row.sample as String
            def r1 = file(row.r1 as String)
            def r2 = file(row.r2 as String)

            // Validate required sample identifier
            if (!sample) {
                error("Missing sample column in manifest row: ${row}")
            }

            // Validate input files exist before running any processes
            if (!r1.exists()) {
                error("File not found for sample ${sample}: ${r1}")
            }
            if (!r2.exists()) {
                error("File not found for sample ${sample}: ${r2}")
            }

            // Emit a standard tuple:
            //   meta map first, then one or more files
            tuple([id: sample], r1, r2)
        }

    // Plasmid Spades
    ch_plasmidspades = PLASMID_SPADES(ch_samples)


    // Annotate Plasmid Assembly
    ch_bakta = BAKTA(ch_plasmidspades.contigs, params.bakta_database)

    publish:
    plasmidspades = ch_plasmidspades.all_results
    annotations = ch_bakta
}

output {
    plasmidspades {
        path "${params.outdir}/"
        mode 'copy'
    }
    annotations {
        path "${params.outdir}/bakta/"
        mode 'copy'
    }
}
