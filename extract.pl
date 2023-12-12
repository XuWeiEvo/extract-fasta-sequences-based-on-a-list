#!/usr/bin/perl
use strict;
use warnings;

# �����ļ���
my $csv_filename = 'list.csv';
my $output_filename_prefix = 'GenBank';  # ����ļ���ǰ׺�������������ļ�������

# ��ȡCSV�ļ��е�Ŀ��������
open my $csv_fh, '<', $csv_filename or die "�޷���CSV�ļ�: $!";
my %target_sequences;
while (<$csv_fh>) {
    chomp;
    $target_sequences{$_} = 1;
}
close $csv_fh;

# ����Ŀ¼�е�FASTA�ļ�
my $input_directory = '.';  # �޸�Ϊ���FASTA�ļ����ڵ�Ŀ¼
opendir my $dir_fh, $input_directory or die "�޷���Ŀ¼: $!";
my @fasta_files = grep { /\.fas$/ } readdir $dir_fh;  # ֻ������չ��Ϊ.fas���ļ�
closedir $dir_fh;

foreach my $fasta_filename (@fasta_files) {
    my $output_filename = $output_filename_prefix . '_' . $fasta_filename;
    
    # ��FASTA�ļ������д���
    open my $fasta_fh, '<', $fasta_filename or die "�޷���FASTA�ļ�: $!";
    open my $output_fh, '>', $output_filename or die "�޷��������FASTA�ļ�: $!";

    my $current_sequence = '';
    while (<$fasta_fh>) {
        chomp;

        if (/^>(\S+)/) {
            $current_sequence = $1;
            # �����ǰ������Ŀ�����У���д������ļ���������
            if (exists $target_sequences{$current_sequence}) {
                print $output_fh "", $_, "\n";
            } else {
                # �����ǰ���в���Ŀ�������б��У������������
                $current_sequence = '';
            }
        } elsif ($current_sequence ne '' && exists $target_sequences{$current_sequence}) {
            # �����ǰ������Ŀ�����У�д������ļ�������������
            print $output_fh $_, "\n";
        }
    }

    close $fasta_fh;
    close $output_fh;

    print "������ȡ��ɣ����������$output_filename�С�\n";
}
