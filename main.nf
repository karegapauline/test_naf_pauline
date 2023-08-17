nextflow.enable.dsl = 2

process COMPRESS {
    label 'compress'
    publishDir params.outdir
    
    input:
    tuple val(name), path(reads)
	
    output:
    tuple val(name), path("${name}*.naf"), emit: compressed_reads
	
script:
    """
    ennaf  ${reads[0]} -o ${name}_1.naf --temp-dir .
    ennaf  ${reads[1]} -o ${name}_2.naf --temp-dir .
    """
}

process DECOMPRESS {
    label 'decompress'
    publishDir params.outdir
    
    input:
    tuple val(name), path(reads)
	
    output:
    tuple val(name), path("${name}*fastq"), emit: decompressed_reads
	
    script:
    """
    unnaf ${reads[0]} -o  ${name}_1.fastq
    unnaf ${reads[1]} -o  ${name}_2.fastq
    """
}

workflow{
    read_pairs_ch = channel.fromFilePairs( params.reads, checkIfExists: true ) 
    COMPRESS(read_pairs_ch)
    DECOMPRESS(COMPRESS.out.compressed_reads)
}

