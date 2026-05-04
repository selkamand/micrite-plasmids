#!/usr/bin/env nextflow

process VIRALVERIFY {
    tag "${meta.id}"
    container 'selkamandcci/micrite-sleuth:0.0.2'

    input:
    tuple val(meta), path(fasta)
    path hmm_db

    output:
    tuple val(meta), path("viralverify")

    script:
    """
    set -euo pipefail

    viralverify -f ${fasta} -o viralverify -t ${task.cpus} -thr 7 -p
    """
}
