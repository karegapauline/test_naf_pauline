nextflow.enable.dsl = 2

process FASTP {
    label 'fastp'
    publishDir params.outdir

    input:
    tuple val(name), path(reads)

    output:
    tuple val(name), path("${name}*.trimmed.fastq"), emit: sample_trimmed
    path "${name}_fastp.json", emit: report_fastp_json
    path "${name}_fastp.html", emit: report_fastp_html

    script:
    """
    fastp -i ${reads[0]} -I ${reads[1]} -o ${name}.R1.trimmed.fastq -O ${name}.R2.trimmed.fastq --detect_adapter_for_pe --json ${name}_fastp.json --html ${name}_fastp.html 
    """
}

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
    FASTP(read_pairs_ch)
    COMPRESS(FASTP.out.sample_trimmed)
    DECOMPRESS(COMPRESS.out.compressed_reads)
}

