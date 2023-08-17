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
    mkdir mytemp
    ennaf -o ${name}_1.naf --temp-dir mytemp ${reads[0]} 
    ennaf -o ${name}_2.naf --temp-dir mytemp ${reads[1]} 
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
    unnaf --fastq ${reads[0]} > ${name}_1.fastq
    unnaf --fastq ${reads[1]} > ${name}_2.fastq
    """
}

workflow{
    read_pairs_ch = channel.fromFilePairs( params.reads, checkIfExists: true ) 
    COMPRESS(read_pairs_ch)
    DECOMPRESS(COMPRESS.out.compressed_reads)
}

