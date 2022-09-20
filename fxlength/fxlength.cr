require "admiral"
require "compress/gzip"
require "./klib"
include Klib




class FaLen < Admiral::Command
	define_argument fafq,
		description: "genome.fa or genome.fa.gz or reads.fq or or reads.fq.gz or -",
		required: true
	define_help description: "A command for ouput sequence length for fasta/fastq format file(use https://github.com/lh3/biofast/blob/master/lib/klib.cr)\nAuthor: ilikeorangeapple@gmail.com. 2019"
	define_version "2.0.0"

	def run
		self.help_when_no_output # when no --help will output help info
		if ARGV.size == 1 && ARGV[0] == "-"
			myexit("error: not  support stdin yet!")
		end
		fafq = arguments.fafq
		fp = GzipReader.new(fafq)
		fx = FastxReader.new(fp)
		while (r = fx.read) >= 0
			#n += 1
			#slen += fx.seq.size
			#qlen += fx.qual.size
			#p! "id=#{fx.name.to_s}\tseq=#{fx.seq.to_s}"
		puts "#{fx.seq.size}\t#{fx.name.to_s}"
		end
		#puts "#{n}\t#{slen}\t#{qlen}"
		raise "ERROR: malformatted FASTX" if r != -1
		fp.close

	end



	def help_when_no_output
		if ARGV.size == 0
			#app = __FILE__.gsub(/\.cr$/, "")
			#puts `#{app} --help`
			#exit 1
			FaLen.run "--help"
		end
	end

	def myexit(content = "", status : Int32 = 1)
		puts content
		exit(status)
	end


end

FaLen.run 

