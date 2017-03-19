# Don't make backups by default
File { backup => false }

# classify nodes via hiera
include lookup('classes', Array[String], 'unique', [])
