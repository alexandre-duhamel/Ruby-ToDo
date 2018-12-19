require 'sqlite3'
require 'date'

$conn = SQLite3::Database.open 'ToDo.db'

def initialise
    $conn.execute("drop table if exists liste")
    $conn.execute("drop table if exists tache")

    $conn.execute(
        "create table liste (
            liste_id integer primary key autoincrement,
            nom string
        )")

    $conn.execute("insert into liste (nom) values ('quetes')")
    $conn.execute("insert into liste (nom) values ('courses')")
    $conn.execute("insert into liste (nom) values ('liste3')")

    $conn.execute(
        "create table tache (
            tache_id integer primary key autoincrement,
            tache string,
            termine int,
            date datetime,
            liste_id integer NOT NULL, FOREIGN KEY (liste_id) REFERENCES liste(liste_id) ON UPDATE CASCADE
        )")

    $conn.execute("insert into tache (liste_id, tache, termine, date) values (1, 'trouver ma nemesis', 0, '1987-09-12')")
    $conn.execute("insert into tache (liste_id, tache, termine, date) values (1, 'faire la paix avec ma nemesis', 0, '2019-12-15')")
    $conn.execute("insert into tache (liste_id, tache, termine, date) values (2, 'faire la vaiselle', 0, '2017-12-15')")
    $conn.execute("insert into tache (liste_id, tache, termine, date) values (2, 'achetter du lait', 0, '2017-12-15')")
    $conn.execute("insert into tache (liste_id, tache, termine, date) values (2, 'promener kiki', 0, '2017-12-15')")
end


def ajouteListe(nom)
    $conn.execute("insert into liste (nom) values ('#{nom}')")
end

def supprimeListe(nom)
    $conn.execute("delete from liste where nom='#{nom}'")
end

def liste(liste)
    $conn.execute("select * from tache where tache.liste_id=(select liste_id from liste where nom='#{liste}')").each do |temp|
       puts  " #{temp[1]} | #{temp[3]} | #{temp[2]}"
    end
end

def affichePlanning
    $conn.execute("select nom from liste").each do |temp|
        puts temp
        liste(temp.to_s.tr('[]"',''))
        puts
    end
end

def ajouteTache (liste, tache, date=Date.today.to_s)
    $conn.execute("insert into tache (liste_id, tache, termine, date) values ((select liste_id from liste where nom='#{liste}'), '#{tache}', 0, '2019-12-15')")
end

def supprimeTache (tache)
    $conn.execute("delete from tache where tache='#{tache}'")
end

def retard
    puts "aujourd'hui: " + Date.today.to_s
    puts "liste | tache | date"
    $conn.execute("select liste.nom, tache, date from tache inner join liste on liste.liste_id=tache.liste_id where (date<'#{Date.today}' and termine=0)").each do |temp|
        puts  "#{temp[0]} | #{temp[1]} | #{temp[2]}"
    end
end

def aujourdhui
    puts "aujourd'hui: " + Date.today.to_s
    $conn.execute("select liste.nom, tache, date from tache inner join liste on liste.liste_id=tache.liste_id where date='#{Date.today}'").each do |temp|
        puts  " #{temp[0]} | #{temp[1]} | #{temp[2]}"
    end
end

def valide(tache)
    $conn.execute("update tache set termine=1 where tache='#{tache}'")
end

def clean
    $conn.execute("delete from tache where termine=1")
end

def help
    puts "Usage: #{__FILE__} <init/list/addList/delList/addTask/delTask/planning/today/late/valid/clean>"
end


if ARGV.empty?
    help
    exit(2)
else
    if ARGV[0]=='init' #initialise avec une bdd pré-remplie
        initialise

    elsif ARGV[0]=='list' #affiche une liste
        liste(ARGV[1])

    elsif ARGV[0]=='addList'
        ajouteListe(ARGV[1])

    elsif ARGV[0]=='delList'
        supprimeListe(ARGV[1])

    elsif ARGV[0]=='planning' #affiche toutes les listes
        affichePlanning

    elsif ARGV[0]=='delTask'
        supprimeTache(ARGV[1])

    elsif ARGV[0]=='addTask'
        ajouteTache(ARGV[1], ARGV[2], ARGV[3])

    elsif ARGV[0]=='today' #affiche les tache du jour
        aujourdhui

    elsif ARGV[0]=='late' #affiche les tache en retard
        retard

    elsif ARGV[0]=='valid' #note 'terminée' un tache
        valide(ARGV[1])

    elsif ARGV[0]=='clean' #supprime toute les tache terminées
        clean
        
    elsif ARGV[0]=='help' 
        help

    else
        help
        exit(2)
    end
end
