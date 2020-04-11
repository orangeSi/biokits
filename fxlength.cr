require "admiral"
require "gzip"



class FaLen < Admiral::Command
	define_argument fafq,
		description: "genome.fa or genome.fa.gz or reads.fq",
		required: false
	define_help description: "A command for ouput sequence length for fasta/fastq format file\nAuthor: ilikeorangeapple@gmail.com. 2019"
	define_version "1.0.0"

	def run
		self.help_when_no_output # when no --help will output help info
		if ARGV.size == 1 && ARGV[0] == "-"
			self.readfasta("", file_type: "stdin")
			exit(0)
		end
		fafile = arguments.fafq || ""
		if fafile.match(/\.fa$/) || fafile.match(/\.fasta$/) || fafile.match(/\.fna$/)
			self.readfasta(fafile, file_type: "fasta") 
		elsif fafile.match(/\.fa.gz$/) || fafile.match(/\.fasta.gz$/) ||fafile.match(/\.fna.gz$/)
			self.readfasta(fafile, file_type: "fasta_gz")
		elsif fafile.match(/\.fq$/) || fafile.match(/\.fastq$/)
			self.readfasta(fafile, file_type: "fastq")
		elsif fafile.match(/\.fq.gz$/) || fafile.match(/\.fastq.gz$/)
			self.readfasta(fafile, file_type: "fastq_gz")
		else
			myexit("error: not support #{fafile}, only fa/fasta/fna/gz\n", 1)
		end
	end


	def readfasta(file : String, file_type = "fasta")
		id,  seqlen = "", 0
		self.yieldfasta(file, file_type) do |line|
			id, seqlen = self.readline(line, id, seqlen)
		end
		id, seqlen = self.readline(">", id, seqlen)
	end


	def yieldfasta(file : String, file_type = "fasta", &block)
		myexit "error: --ref #{file} not exists" if file != ""  && ! File.exists?(file)
		#puts "file_type is #{file_type}"
		if file_type == "fasta"
			File.each_line(file) do |line|
				yield line
			end
		elsif file_type == "stdin"
			STDIN.each_line do |line|
				yield line
			end
		elsif file_type == "fasta_gz"
			Gzip::Reader.open(file) do |gfile|
				gfile.each_line do |line|
					yield line
				end
			end
		elsif file_type == "fastq"
			i = 0
			File.each_line(file) do |line|
				i +=1
				if i%4 == 1 || i%4 == 2
					yield line
				end
			end
			i = 0
		elsif file_type == "fastq_gz"
			i = 0
			Gzip::Reader.open(file) do |gfile|
				gfile.each_line do |line|
					i +=1
					if i%4 == 1 || i%4 == 2
						yield line
					end
				end
			end
			i = 0
		else
			raise "error: not support file_type=#{file_type}, only len or fasta"
		end
	end

	def readline(line : String, id : String, seqlen : Int32)
		if line.starts_with?('>')
			if id != "" || seqlen != 0
				id_short = id.sub(/^./, "").sub(/\s.*$/, "")
				raise "error: got one empyt sequence id\n" if id_short.starts_with?(/^\s*$/)
				puts "#{seqlen}\t"+id_short
			end
			id = line
			seqlen = 0
		else
			seqlen += line.strip.size
		end
		return id, seqlen
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

