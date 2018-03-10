# Don't make backups by default
File { backup => false }

# classify nodes via hiera
contain lookup('classes', Array[String], 'unique', [])
