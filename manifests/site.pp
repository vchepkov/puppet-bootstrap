# classify nodes via hiera
contain lookup('classes', Array[String], 'unique', [])
