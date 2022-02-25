require "admiral"
require "gzip"



class FaLen < Admiral::Command
	define_argument fafq,
		description: "genome.fa or genome.fa.gz or reads.fq or or reads.fq.gz or -",
		required: true
	define_help description: "A command for ouput sequence length for fasta/fastq format file\nAuthor: ilikeorangeapple@gmail.com. 2019"
	define_version "1.0.0"

	def run
		self.help_when_no_output # when no --help will output help info
		if ARGV.size == 1 && ARGV[0] == "-"
			io = IO::Memory.new
			IO.copy STDIN, io, 1
			while io.to_s[-1] != '>' && io.to_s[-1] != '@'
				IO.copy STDIN, io, 1
			end
			if io.to_s[-1] == '>'
				self.readfastx("", file_type: "fasta_stdin") 
			elsif io.to_s[-1] == '@'
				self.readfastx("", file_type: "fastq_stdin") 
			else	
				puts "error: only support fastq/fastq instead of start with #{io.to_s} from stdin"
				exit(1)
			end
			exit(0)
		end
		fafile = arguments.fafq || ""
		if fafile.match(/\.fa$/) || fafile.match(/\.fasta$/) || fafile.match(/\.fna$/)
			self.readfastx(fafile, file_type: "fasta") 
		elsif fafile.match(/\.fa.gz$/) || fafile.match(/\.fasta.gz$/) ||fafile.match(/\.fna.gz$/)
			self.readfastx(fafile, file_type: "fasta_gz")
		elsif fafile.match(/\.fq$/) || fafile.match(/\.fastq$/)
			self.readfastx(fafile, file_type: "fastq")
		elsif fafile.match(/\.fq.gz$/) || fafile.match(/\.fastq.gz$/)
			self.readfastx(fafile, file_type: "fastq_gz")
		else
			#self.exit("error: not support #{fafile}, only fa/fasta/fna/gz\n", 1)
			raise("error: not support #{fafile}, only fa/fasta/fna/gz\n")
		end
	end


	def readfastx(file : String, file_type = "fasta")
		id,  seqlen = "", 0
		flag = 0
		if file_type == "fasta" || file_type == "fasta_gz" || file_type == "fasta_stdin"
			self.yieldfastx(file, file_type) do |line|
				if flag == 0 && file_type == "fasta_stdin"
					line = ">" + line
					flag +=1
				end
				id, seqlen = self.readfaline(line, id, seqlen)
			end
			id, seqlen = self.readfaline(">", id, seqlen)
		elsif file_type == "fastq" || file_type == "fastq_gz" || file_type == "fastq_stdin"
			line_num = 0
			self.yieldfastx(file, file_type) do |line|
				line_num +=1
				if flag == 0 && file_type == "fastq_stdin"
					line = "@" + line
					flag +=1
				end
				id, line_num = self.readfqline(line, id, line_num)
			end
		else
			#self.exit("error: only support fasta or fastq", 1)
			raise("error: only support fasta or fastq or stdin")

		end
	end


	def yieldfastx(file : String, file_type = "fasta", &block)
		raise("error: --ref #{file} not exists") if file != ""  && ! File.exists?(file)
		if file_type == "fasta"
			File.each_line(file) do |line|
				yield line
			end
		elsif file_type == "fasta_stdin" || file_type == "fastq_stdin"
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
			File.each_line(file) do |line|
				yield line
			end
		elsif file_type == "fastq_gz"
			Gzip::Reader.open(file) do |gfile|
				gfile.each_line do |line|
					yield line
				end
			end
		else
			raise "error: not support file_type=#{file_type}, only len or fasta"
		end
	end

	def readfaline(line : String, id : String, seqlen : Int32)
		if line.starts_with?('>')
			if id != "" || seqlen != 0
				id_short = id.sub(/^>*/, "").sub(/\s.*$/, "")
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

	def readfqline(line : String, id : String, line_num : Int32)
		i = line_num % 4
		if i == 1
			id = line
		elsif i == 2
			puts "#{line.size}\t#{id.lstrip("@")}"
		elsif i == 0
			line_num = 0
		end
		return id, line_num
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

