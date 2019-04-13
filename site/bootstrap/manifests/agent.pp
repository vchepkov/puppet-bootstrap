# Configure puppet agent
class bootstrap::agent {
  include chrony
  include git
}
