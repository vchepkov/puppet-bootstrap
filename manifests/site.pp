# Don't make backups by default
File { backup => false }

# classify nodes via hiera
hiera_include('classes')
