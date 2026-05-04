#!/usr/bin/env nextflow

process BLAST_KNOWN_PLASMIDS {
    tag "${meta.id}"

    container "community.wave.seqera.io/library/blast:2.17.0--d4fb881691596759"
    cpus 1

    input:
    tuple val(meta), path(fasta)
    path database

    output:
    tuple val(meta), path("${meta.id}.blastn.tsv")

    script:
    """
    set -euo pipefail
    
    blastn -db ${database} \
    -evalue 1e-10 \
    -max_target_seqs 20 \
    -outfmt '7 std staxid qcovs qcovhsp stitle' \
    -perc_identity 90 -max_hsps 10 -subject_besthit \
    -out ${meta.id}.blastn.tsv \
    -query  ${fasta}
    """
}
