require 'sqlite3'
require 'fileutils'

# Define la ubicación del backup y la carpeta de destino
backup_directory = '/Users/[user]/Downloads/Backups/00008110-0014344026F1401E'
destination_directory = '/Users/[user]/Documents/Project/RubyIphoneExtractor/files'
manifest_db_path = File.join(backup_directory, 'Manifest.db')

# Asegúrate de que el directorio de destino existe
Dir.mkdir(destination_directory) unless File.exist?(destination_directory)

# Conecta a la base de datos SQLite
db = SQLite3::Database.new(manifest_db_path)

# Consulta para obtener la información de los memos de voz
query = "SELECT fileID, relativePath FROM Files WHERE relativePath LIKE '%Recordings%' AND relativePath LIKE '%.m4a'"

begin
  # Ejecuta la consulta
  db.execute(query) do |row|
    file_id, relative_path = row
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

puts "Los memos de voz han sido extraídos al directorio: #{destination_directory}"