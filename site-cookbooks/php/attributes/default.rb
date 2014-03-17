###
# Install Settings
###

# Version
default['libiconv']['version'] = "libiconv-1.14"
default['re2c']['version'] = "re2c-0.13.5"
default['php']['version'] = "php-5.5.4"

# Directory
default['php']['src_dir']    = "/usr/local/src/"
default['php']['conf_dir']   = "/usr/local/#{php['version']}/lib/"
default['php']['apache_dir'] = "/usr/local/apache/"

# User
default['php']['install_user']  = "root"
default['php']['install_group'] = "root"

# Configure Options
# skip --enable-mbregex
# skip --with-config-file-path=#{php['conf_dir']}
# skip --enable-zend-multibyte
# skip --enable-bcmath
# skip --with-pdo-mysql=/usr/local/mysql
default['php']['configure'] = %W{--prefix=/usr/local/#{php['version']}
                                 --with-apxs2=#{php['apache_dir']}bin/apxs
                                 --with-mysql
                                 --with-pdo-mysql
                                 --with-mysqli=mysqlnd
                                 --enable-mbstring
                                 --enable-libgcc
                                 --enable-pcntl
                                 --with-zlib
                                 --with-openssl
                                 --with-curl
                                 --with-config-file-scan-dir=/usr/local/#{php['version']}/lib/conf.d}


###
# Conf Settings
###

# Output
default['php']['output_buffering'] = "On"
default['php']['output_handler']   = "mb_output_handler"
default['php']['expose_php']       = "Off"
default['php']['error_reporting']  = "E_ALL"

# Timezone
default['php']['date']['timezone'] = "Asia/Tokyo"

# Session
default['php']['session']['entropy_length'] = 32
default['php']['session']['entropy_file']   = "/dev/urandom"
default['php']['session']['hash_function']  = 1

# Mbstring
default['php']['mbstring']['internal_encoding']    = "UTF-8"
default['php']['mbstring']['http_input']           = "pass"
default['php']['mbstring']['http_output']          = "UTF-8"
default['php']['mbstring']['encoding_translation'] = "Off"
default['php']['mbstring']['detect_order']         = "auto"
