# Create simple web page
class profile::www::webpage {
  file { 'C:/inetpub/wwwroot/iisstart.htm':
    ensure  => file,
    content => epp('www/iisstart.htm.epp'),
  }
}
