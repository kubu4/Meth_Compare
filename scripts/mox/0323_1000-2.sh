#!/bin/bash
## Job Name
#SBATCH --job-name=Pact-C1-2
##  Aligning Pact to C1
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes (We only get 1, so this is fixed)
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sr320@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/sr320/032320-Pact-C1


# Directories and programs
bismark_dir="/gscratch/srlab/programs/Bismark-0.21.0"
bowtie2_dir="/gscratch/srlab/programs/bowtie2-2.3.4.1-linux-x86_64/"
samtools="/gscratch/srlab/programs/samtools-1.9/samtools"

source /gscratch/srlab/programs/scripts/paths.sh


# ${bismark_dir}/bismark_genome_preparation \
# --verbose \
# --parallel 28 \
# --path_to_aligner ${bowtie2_dir} \
# ${genome_folder}




genome_folder="/gscratch/srlab/sr320/data/froger/C1_Genome/"
reads_dir="/gscratch/scrubbed/sr320/031520-TG-bs/Pact_trim/"


# find ${reads_dir}*_R1_001_val_1.fq.gz \
# | xargs basename -s _R1_001_val_1.fq.gz | xargs -I{} ${bismark_dir}/bismark \
# --path_to_bowtie ${bowtie2_dir} \
# -genome ${genome_folder} \
# -p 4 \
# -score_min L,0,-0.6 \
# --non_directional \
# -1 ${reads_dir}{}_R1_001_val_1.fq.gz \
# -2 ${reads_dir}{}_R2_001_val_2.fq.gz \
# -o Pact_C1
#



--------------------------------------------------------

# From here we extract methylation and create downstream amendable files.
# will split samples into dedup and nodedup directories for reasson
# RRBS data does NOT need to be deplicated
# First the dedups which in our case would be


# mkdir Pact_C1/dedup
# cp Pact_C1/Meth1*bam Pact_C1/dedup/
# cp Pact_C1/Meth2*bam Pact_C1/dedup/
# cp Pact_C1/Meth3*bam Pact_C1/dedup/
# cp Pact_C1/Meth7*bam Pact_C1/dedup/
# cp Pact_C1/Meth8*bam Pact_C1/dedup/
# cp Pact_C1/Meth9*bam Pact_C1/dedup/

mkdir Pact_C1/nodedup
cp Pact_C1/Meth4*bam Pact_C1/nodedup/
cp Pact_C1/Meth5*bam Pact_C1/nodedup/
cp Pact_C1/Meth6*bam Pact_C1/nodedup/

#
# cd Pact_C1/dedup
#
#
# find *.bam | \
# xargs basename -s .bam | \
# xargs -I{} ${bismark_dir}/deduplicate_bismark \
# --bam \
# --paired \
# {}.bam
#
#
#
# ${bismark_dir}/bismark_methylation_extractor \
# --bedGraph --counts --scaffolds \
# --multicore 14 \
# --buffer_size 75% \
# *deduplicated.bam
#
#
#
# # Bismark processing report
#
# ${bismark_dir}/bismark2report
#
# #Bismark summary report
#
# ${bismark_dir}/bismark2summary
#
#
#
# # Sort files for methylkit and IGV
#
# find *deduplicated.bam | \
# xargs basename -s .bam | \
# xargs -I{} ${samtools} \
# sort --threads 28 {}.bam \
# -o {}.sorted.bam
#
# # Index sorted files for IGV
# # The "-@ 16" below specifies number of CPU threads to use.
#
# find *.sorted.bam | \
# xargs basename -s .sorted.bam | \
# xargs -I{} ${samtools} \
# index -@ 28 {}.sorted.bam
#
#
#
#
# find *deduplicated.bismark.cov.gz \
# | xargs basename -s deduplicated.bismark.cov.gz \
# | xargs -I{} ${bismark_dir}/coverage2cytosine \
# --genome_folder ${genome_folder} \
# -o {} \
# --merge_CpG \
# --zero_based \
# {}deduplicated.bismark.cov.gz
#
#
# #creating bedgraphs post merge
#
# for f in *merged_CpG_evidence.cov
# do
#   STEM=$(basename "${f}" .CpG_report.merged_CpG_evidence.cov)
#   cat "${f}" | awk -F $'\t' 'BEGIN {OFS = FS} {if ($5+$6 >= 10) {print $1, $2, $3, $4}}' \
#   > "${STEM}"_10x.bedgraph
# done
#
#
#
# for f in *merged_CpG_evidence.cov
# do
#   STEM=$(basename "${f}" .CpG_report.merged_CpG_evidence.cov)
#   cat "${f}" | awk -F $'\t' 'BEGIN {OFS = FS} {if ($5+$6 >= 5) {print $1, $2, $3, $4}}' \
#   > "${STEM}"_5x.bedgraph
# done
#
#
# #creating tab files with raw count for glms
#
# for f in *merged_CpG_evidence.cov
# do
#   STEM=$(basename "${f}" .CpG_report.merged_CpG_evidence.cov)
#   cat "${f}" | awk -F $'\t' 'BEGIN {OFS = FS} {if ($5+$6 >= 10) {print $1, $2, $3, $4, $5, $6}}' \
#   > "${STEM}"_10x.tab
# done
#
#
# for f in *merged_CpG_evidence.cov
# do
#   STEM=$(basename "${f}" .CpG_report.merged_CpG_evidence.cov)
#   cat "${f}" | awk -F $'\t' 'BEGIN {OFS = FS} {if ($5+$6 >= 5) {print $1, $2, $3, $4, $5, $6}}' \
#   > "${STEM}"_5x.tab
# done
#
#
# ------------------------
#

cd Pact_C1/nodedup


${bismark_dir}/bismark_methylation_extractor \
--bedGraph --counts --scaffolds \
--multicore 14 \
--buffer_size 75% \
*.bam



# Bismark processing report

${bismark_dir}/bismark2report

#Bismark summary report

${bismark_dir}/bismark2summary



# Sort files for methylkit and IGV

find *.bam | \
xargs basename -s .bam | \
xargs -I{} ${samtools} \
sort --threads 28 {}.bam \
-o {}.sorted.bam

# Index sorted files for IGV
# The "-@ 16" below specifies number of CPU threads to use.

find *.sorted.bam | \
xargs basename -s .sorted.bam | \
xargs -I{} ${samtools} \
index -@ 28 {}.sorted.bam



find *bismark.cov.gz \
| xargs basename -s bismark.cov.gz \
| xargs -I{} ${bismark_dir}/coverage2cytosine \
--genome_folder ${genome_folder} \
-o {} \
--merge_CpG \
--zero_based \
{}bismark.cov.gz


#creating bedgraphs post merge

for f in *merged_CpG_evidence.cov
do
  STEM=$(basename "${f}" .CpG_report.merged_CpG_evidence.cov)
  cat "${f}" | awk -F $'\t' 'BEGIN {OFS = FS} {if ($5+$6 >= 10) {print $1, $2, $3, $4}}' \
  > "${STEM}"_10x.bedgraph
done



for f in *merged_CpG_evidence.cov
do
  STEM=$(basename "${f}" .CpG_report.merged_CpG_evidence.cov)
  cat "${f}" | awk -F $'\t' 'BEGIN {OFS = FS} {if ($5+$6 >= 5) {print $1, $2, $3, $4}}' \
  > "${STEM}"_5x.bedgraph
done


#creating tab files with raw count for glms

for f in *merged_CpG_evidence.cov
do
  STEM=$(basename "${f}" .CpG_report.merged_CpG_evidence.cov)
  cat "${f}" | awk -F $'\t' 'BEGIN {OFS = FS} {if ($5+$6 >= 10) {print $1, $2, $3, $4, $5, $6}}' \
  > "${STEM}"_10x.tab
done


for f in *merged_CpG_evidence.cov
do
  STEM=$(basename "${f}" .CpG_report.merged_CpG_evidence.cov)
  cat "${f}" | awk -F $'\t' 'BEGIN {OFS = FS} {if ($5+$6 >= 5) {print $1, $2, $3, $4, $5, $6}}' \
  > "${STEM}"_5x.tab
done
