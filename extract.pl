#!/usr/bin/perl
use strict;
use warnings;

# 输入文件名
my $csv_filename = 'list.csv';
my $output_filename_prefix = 'GenBank';  # 输出文件名前缀，将根据输入文件名生成

# 读取CSV文件中的目标序列名
open my $csv_fh, '<', $csv_filename or die "无法打开CSV文件: $!";
my %target_sequences;
while (<$csv_fh>) {
    chomp;
    $target_sequences{$_} = 1;
}
close $csv_fh;

# 处理目录中的FASTA文件
my $input_directory = '.';  # 修改为你的FASTA文件所在的目录
opendir my $dir_fh, $input_directory or die "无法打开目录: $!";
my @fasta_files = grep { /\.fas$/ } readdir $dir_fh;  # 只处理扩展名为.fas的文件
closedir $dir_fh;

foreach my $fasta_filename (@fasta_files) {
    my $output_filename = $output_filename_prefix . '_' . $fasta_filename;
    
    # 打开FASTA文件，逐行处理
    open my $fasta_fh, '<', $fasta_filename or die "无法打开FASTA文件: $!";
    open my $output_fh, '>', $output_filename or die "无法创建输出FASTA文件: $!";

    my $current_sequence = '';
    while (<$fasta_fh>) {
        chomp;

        if (/^>(\S+)/) {
            $current_sequence = $1;
            # 如果当前序列是目标序列，则写入输出文件的描述行
            if (exists $target_sequences{$current_sequence}) {
                print $output_fh "", $_, "\n";
            } else {
                # 如果当前序列不在目标序列列表中，跳过这个序列
                $current_sequence = '';
            }
        } elsif ($current_sequence ne '' && exists $target_sequences{$current_sequence}) {
            # 如果当前序列是目标序列，写入输出文件的序列数据行
            print $output_fh $_, "\n";
        }
    }

    close $fasta_fh;
    close $output_fh;

    print "序列提取完成，结果保存在$output_filename中。\n";
}
