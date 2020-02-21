#!/bin/bash
####################
#This script extracts a set of target loci (in a fasta file Queries.fasta) from a set of assembled genomes (in a dir called Genomes/).
#The output is one file per genome that contains all target loci, named as >Genome_target_locus_genome_scaffold_info. 
#There may be more than one sequence per genome x locus if a locus is not single copy in that genome. default blast search options 
#are used and should be changed as needed.
####################
#load modules
module load ncbi_blast/2.9.0
module load bedtools
#loop through a set of genomes in a dir named Genomes (can be changed here, filepath is not used again- is saved as variable)
for i in Genomes/*fna
do
#make blastdb (comment next line out if db already exists)
makeblastdb -type nucl -in $i -parse_seqids
#Set variable $Organism equal to the name of the genome file without the filepath or file ending (so /ufrc/soltis/hkates/Csativus.fna = "Csativus"). Assumes file ending is fna. Change if needed.
Organism=`basename $i .fna`
#blast a list of target sequences (in Queries.fasta, change name if needed) against db
blastn -db $i -query Queries.fasta -outfmt 6 > $Organism.bls
#convert blast table (-outfmt 6) to bed file format
grep -v '^#' ${Organism}.bls | perl -ane 'if($F[8]<=$F[9]){print join("\t",$F[1],$F[8]-1,$F[9],$F[0],"0","+"),"\n";}else{print join("\t",$F[1],$F[9]-1,$F[8],$F[0],"0","-"),"\n";}' | sort >> $Organism.$
#bedtools to extract the sequences from the genomes based on blast hits. This will extract all hits, so there may be multiple seqs per target locus if no other filtering is done.
bedtools getfasta -s -name -fi Genomes/$Organism.fna -bed $Organism.bed -fo $Organism.target_loci.fasta
#add the organism name to the headers
sed -i "s/>/>${Organism}_/g" $Organism.target_loci.fasta
done
