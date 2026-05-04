#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params {
    // Sample sheet (csv) with three named columsn: sample, r1, r2 describing sampleids
    input: Path

    // Path to bakta database directory
    bakta_database: Path? = null

    // Path to mobsuite database directory
    mobsuite_database: Path? = null

    // Path to viralverify HMM database
    viralverify_database: Path? = null

    // Output directory name
    outdir: String = "micrite_plasmid"
}

include { PLASMID_SPADES } from './modules/local/plasmidspades.nf'
include { BAKTA } from './modules/local/bakta.nf'
include { VIRALVERIFY } from './modules/local/viralverify.nf'
include { MOBSUITE } from './modules/local/mob_suite.nf'

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


    // Annotate Plasmid Assembly if user supplies bakta database
    ch_bakta = channel.empty()
    if (params.bakta_database != null) {
        ch_bakta = BAKTA(ch_plasmidspades.scaffolds, params.bakta_database)
    }

    // Run mobsuite on Plasmid assembly if user supplies mobsuite database
    ch_mobsuite = channel.empty()
    if (params.mobsuite_database != null) {
        ch_mobsuite = MOBSUITE(ch_plasmidspades.scaffolds, params.mobsuite_database)
    }

    // Classify plasmid spades output with viralverify 
    ch_viralverify = channel.empty()
    if (params.viralverify_database != null) {
        ch_viralverify = VIRALVERIFY(ch_plasmidspades.scaffolds, params.viralverify_database)
    }

    publish:
    plasmidspades = ch_plasmidspades.all_results
    annotations = ch_bakta
    mobsuite = ch_mobsuite
    viralverify = ch_viralverify
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
    mobsuite {
        path "${params.outdir}/mobsuite/"
        mode 'copy'
    }
    viralverify {
        path "${params.outdir}/viralverify/"
        mode 'copy'
    }
}
