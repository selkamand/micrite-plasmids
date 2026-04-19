# micrite-plasmid


Search a fastq for plasmids. 

1) Runs plasmidSpades.py


## Quick Start 

Create a sample sheet (csv) with named columns 

1. **sample** - sample identifier 
2. **r1** - forward reads (fastq)
3. **r2** - reverse reads (fastq)

Save to 'samplesheet.csv' and run:


```
nextflow run selkamand/micrite-plasmid -profile docker
```

> [!NOTE]
> You may need to change -profile to singularity / apptainer / podman / etc. depending on what container manager you use. 


## Testing the pipeline

Before you begin, check the test profile runs well on your machine:

```

nextflow run selkamand/micrite-plasmid -profile docker,test
```
