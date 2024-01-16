require 'sqlite3'
require 'fileutils'

# Define la ubicación del backup y la carpeta de destino
backup_directory = '/Users/[user]/Downloads/Backups/[id_device_bk]'
destination_directory = '/Users/[user]/Documents/Project/RubyIphoneExtractor/images'
manifest_db_path = File.join(backup_directory, 'Manifest.db')

# Asegúrate de que el directorio de destino existe
Dir.mkdir(destination_directory) unless File.exist?(destination_directory)

# Conecta a la base de datos SQLite
db = SQLite3::Database.new(manifest_db_path)

# Consulta para obtener la información de las imágenes
query = <<-SQL
  SELECT fileID, relativePath FROM Files 
  WHERE relativePath LIKE '%.png' 
     OR relativePath LIKE '%.jpg' 
     OR relativePath LIKE '%.jpeg' 
     OR relativePath LIKE '%.heic'
SQL

begin
  # Ejecuta la consulta
  db.execute(query) do |row|

    puts "Row: #{row}"
    puts "Query: #{query}"
    sleep 0.1 # Para evitar errores de lectura de la base de datos
    file_id, relative_path = row
    next if relative_path.nil? || relative_path.empty?

    filename = file_id[0..1] # Los archivos están en subdirectorios nombrados por los primeros 2 caracteres del fileID
    source_file_path = File.join(backup_directory, filename, file_id)
    
    # Crea un nombre de archivo válido para el sistema de archivos del destino
    valid_file_name = File.basename(relative_path).gsub(/[^0-9A-Za-z.\-]/, '_')

    destination_file_path = File.join(destination_directory, valid_file_name)

    # Copia el archivo al directorio de destino con su nombre original
    FileUtils.cp(source_file_path, destination_file_path) if File.exist?(source_file_path)
  end
rescue SQLite3::SQLException => e
  puts "Ha ocurrido un error al realizar la consulta a la base de datos: #{e.message}"
ensure
  db.close if db
end

puts "Las imágenes han sido extraídas al directorio: #{destination_directory}"
