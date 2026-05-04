#!/usr/bin/env nextflow

process VIRALVERIFY {
    tag "${meta.id}"
    container 'community.wave.seqera.io/library/viralverify:1.1--3527fad4ef7ee6f4'

    input:
    tuple val(meta), path(fasta)
    path hmm_db

    output:
    tuple val(meta), path("viralverify")

    script:
    """
    set -euo pipefail

    viralverify -f ${fasta} -o viralverify -t ${task.cpus} --thr 7 -p
    """
}
