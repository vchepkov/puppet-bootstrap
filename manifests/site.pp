# Don't make backups by default
Concat_file { backup => false }
File { backup => false }

# classify nodes via hiera
contain lookup('classes', Array[String], 'unique', [])
