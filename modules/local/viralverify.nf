#!/usr/bin/env nextflow

process VIRALVERIFY {
    tag "${meta.id}"
    container 'community.wave.seqera.io/library/viralverify:1.1--3527fad4ef7ee6f4'

    input:
    tuple val(meta), path(fasta)
    path hmm_database

    output:
    tuple val(meta), path("viralverify/viralverify/")

    script:
    """
    set -euo pipefail

    viralverify --hmm ${hmm_database} -f ${fasta} -o viralverify -t ${task.cpus} --thr 7 -p
    """
}
