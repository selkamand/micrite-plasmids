#!/usr/bin/env nextflow

process MOBSUITE {
    tag "${meta.id}"
    container "community.wave.seqera.io/library/mob_suite:3.1.9--3a18f48476cb8fba"

    input:
    tuple val(meta), path(fasta)
    path database

    output:
    tuple val(meta), path("mob_typer"), path("mob_recon")

    script:
    """
    set -euo pipefail

    mob_recon -d ${database} --infile  ${fasta} --outdir mob_recon
    mob_typer -d ${database} -i ${fasta} -o mob_typer
    """
}
