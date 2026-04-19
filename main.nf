#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params {
    // Sample sheet (csv) with three named columsn: sample, r1, r2 describing sampleids
    input: Path
    outdir: Path = "micrite_plasmid"
}

include { PLASMID_SPADES } from './modules/local/plasmidspades.nf'

workflow {

    main:
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

    ch_plasmidspades = PLASMID_SPADES(ch_samples)

    publish:
    plasmidspades = ch_plasmidspades.all_results
}

output {
    plasmidspades {
        path "${params.outdir}/"
        mode 'copy'
    }
}
