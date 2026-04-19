// Run plasmid spades from paired FASTQ files
process PLASMID_SPADES {
    tag "${meta.id}"
    container 'selkamandcci/micrite-sleuth:0.0.2'

    input:
    tuple val(meta), path(r1), path(r2)

    output:
    tuple val(meta), path("plasmid_assembly/contigs.fasta"), emit: contigs
    tuple val(meta), path("plasmid_assembly/scaffolds.fasta"), emit: scaffolds
    tuple val(meta), path("plasmid_assembly"), emit: all_results

    script:
    """
    set -euo pipefail
 
    spades.py --threads ${task.cpus} --plasmid -1 ${r1} -2 ${r2} -o "plasmid_assembly"
    """
}
