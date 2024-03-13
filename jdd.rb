require "gtk3"

Gtk.init

window = Gtk::Window.new
window.set_default_size(400,250)
window.set_title("Jeu du dictionnaire")
window.set_icon("dico.ico")
window.signal_connect("destroy") {Gtk.main_quit}

def nouveau
	File::open("words.txt", "r") do |liste|
		@mots = liste.readlines
	end
	lim = @mots.length
	nb = rand(lim)
	@mot = @mots[nb]
    @lettres = (@mot.length - 1).to_s
	@debut = Time.new
	@trouve = false
	@a = @mots[(lim-1)]
	@aa = nil
	@b = @mots[0]
	@bb = nil
	@coups = 0
end

def highscore
	File::open("scores.txt", "r") do |file|
		lines = file.readlines
		lines = lines.sort
		@coups = "0" + @coups if @coups.length == 1
		@duree = @duree.to_s
		@duree = "0" + @duree if @duree.length == 2
		if lines[9] == nil or @coups < lines[9]
			@name = Gtk::Entry.new
			@name.set_activates_default(true)
			@name.text=("Entrez votre nom")
			@score = Gtk::MessageDialog.new(:parent => @popup, :flags => :modal, :type => :info, :buttons => :ok)
			@score.set_icon("dico.ico")
			@score.set_default_response(:ok)
			@score.child.pack_start(@name, :expand => false)
			@score.child.show_all
            @score.set_title("Nouveau score !")
			reponse = @score.run
			while reponse != :ok
				reponse = @score.run
			end
			joueur = @name.text.capitalize + "\n"
			@score.destroy
			File::open("scores.txt", "a") do |file|
			file << @coups + ' coups en ' + @duree + ' secondes (' + @mot.chomp + '), joué par ' + joueur
			end
		end
	end
end

def rejouer
	rejouer = @popup.run
	if rejouer == :yes
		@trouve = true
		@intro.set_text("")
		@popup.destroy
		nouveau
        @label.set_text("On cherche un mot de " + @lettres + " lettres...")
        @label2.set_text("")
	else
		Gtk.main_quit
	end
end

nouveau
vb = Gtk::Box.new(:vertical, 0)

menu = Gtk::Table.new(1,5)
jeu = Gtk::Button.new(:label => "Jeu")
jeu.set_relief(:none)
jeu.signal_connect("clicked") {
	@popup = Gtk::MessageDialog.new(:parent => window, :flags => :modal, :type => :warning, :buttons => :yes_no,
	:message => "Nouvelle partie ?")
	@popup.set_title("Jeu")
    rejouer
}
menu.attach(jeu,0,1,0,1,:shrink)

options = Gtk::Button.new(:label => "Options")
options.set_relief(:none)
options.signal_connect("clicked") {
	opts = Gtk::MessageDialog.new(:parent => window, :flags => :modal, :type => :info, :buttons => :close,
	:message => "Cette fonctionnalité n'est pas encore disponible")
	opts.set_title("Options")
	opts.run
	opts.destroy
}
menu.attach(options,1,2,0,1,:shrink)

scores = Gtk::Button.new(:label => "Scores")
scores.set_relief(:none)
scores.signal_connect("clicked") {
	hisc = Gtk::MessageDialog.new(:parent => window, :flags => :modal, :type => :info, :buttons => :close,
    :message => "Voici les 10 meilleurs scores obtenus par le passé :")
	File::open("scores.txt", "r") do |file|
		lines = file.readlines
		lines = lines.sort
		@lines = lines[0..9]
	end
    for line in @lines
        score = Gtk::Label.new(line.chomp)
	    hisc.child.pack_start(score)
    end
	hisc.child.show_all
    hisc.set_title("Scores")
	hisc.run
	hisc.destroy
}
menu.attach(scores,2,3,0,1,:shrink)

aide = Gtk::Button.new(:label => "Aide")
aide.set_relief(:none)
aide.signal_connect("clicked") {
	help = Gtk::MessageDialog.new(:parent => window, :flags => :modal, :type => :question, :buttons => :close, 
	:message => "Le but du jeu est de trouver un mot français en un minimum d'essais. 
Pour chaque tentative, le dictionnaire répond si c'est AVANT ou APRÈS, reduisant ainsi le champ des possibilités.

Pour savoir combien de coups vous avez déjà faits, tapez c?
Pour afficher à nouveau le nombre de lettres, tapez l?
Pour donner votre langue au chat, tapez simplement ?")
	help.set_title("Aide")
	help.run
	help.destroy
}
menu.attach(aide,3,4,0,1,:shrink)

chrono = Gtk::Label.new("00:00")
tps = (Time.new-@debut).to_i
if tps < 10
  actu = "00:0" + tps.to_s
elsif tps < 60
  actu = "00:" + tps.to_s
elsif tps < 600
  mins = tps/60
  secs = tps%60
  actu = "0" +mins.to_s+ ":" +secs.to_s
end
chrono.set_text(actu)
#menu.attach(chrono, 4,5,0,1)

vb.pack_start(menu)
@intro = Gtk::Label.new("")
vb.pack_start(@intro)
hb = Gtk::Box.new(:horizontal, 0)
champ = Gtk::Entry.new
champ.signal_connect("activate") {
	try = champ.text.downcase + "\n"
	champ.text=("")
	if try == @mot # Victoire
		@coups = (@coups+1).to_s
		fin = Time.new
		@duree = (fin - @debut).to_i
		min = @duree/60
		sec = @duree%60
		@temps = ""
		@temps = (@temps + min.to_s+ " min. ") if min > 0
		@temps = @temps + sec.to_s+ " sec."
		@popup = Gtk::MessageDialog.new(:parent => window, :flags => :modal, :type => :info, :buttons => :yes_no, 
			:message => "Bien joué !\nC'était effectivement " +@mot.chomp.upcase+ ".\n\nTrouvé en " +@coups+ " coups.\nTemps : " +@temps+ "\n\nRejouer ?")
		@popup.set_title("Victoire !")
		highscore if @coups.to_i < 100
		rejouer
    elsif @mots.include?(try) and (try == @b or try == @a)
		@label.set_text("Tu as déjà essayé le mot " + try.chomp.upcase + " !")
	elsif @mots.include?(try) and (@mots.index(try) < @mots.index(@b) or @mots.index(try) > @mots.index(@a))
		@label.set_text("Revois ton ordre alphabétique !")
	elsif @mots.include?(try) and @mots.index(try) > @mots.index(@mot)
		@label.set_text("Non, c'est AVANT " + try.chomp)
		@a = try if (@mots.index(try) < @mots.index(@a))
		@aa = @a.chomp.upcase
		@coups +=1
	elsif @mots.include?(try) and @mots.index(try) < @mots.index(@mot)
		@label.set_text("Non, c'est APRÈS " + try.chomp)
		@b = try if (@mots.index(try) > @mots.index(@b))
		@bb = @b.chomp.upcase
		@coups +=1
	elsif try.chomp == '?' # Abandon
		@popup = Gtk::MessageDialog.new(:parent => window, :flags => :modal, :type => :warning, :buttons => :yes_no, 
			:message => "Tu donnes ta langue au chat ?\nC'etait " + @mot.chomp.upcase + " !\n\n Rejouer ?")
		@popup.set_title("Dommage...")
		rejouer
	elsif try.chomp == ""
		@label.set_text("Entrez un mot")
	elsif try.chomp == "l?"
		lettres = (@mot.length - 1).to_s
		@label.set_text("C'est un mot de " + @lettres + " lettres...")
	elsif try.chomp == "c?"
        if @coups == 1 then essai = "essai" else essai = "essais" end
		@label.set_text("Vous avez déjà fait " + @coups.to_s + " " + essai + ".")
    elsif try.length < 4
		@label.set_text("Les mots de moins de 3 lettres ne sont pas pris en compte.")
	else
		@label.set_text("Le mot " + try.chomp.upcase + " n'est pas admis...")
	end
    if @aa and not @bb
        @bb = @b.chomp.upcase
    elsif @bb and not @aa
        @aa = @a.chomp.upcase
    end
	@label2.set_text("C'est donc entre " + @bb + " et " + @aa + ".\n") if (@aa and @bb) unless @trouve
}
hb.pack_start(champ, :expand => true, :fill => true, :padding => 5)
b = Gtk::Button.new(:label => "OK")
b.signal_connect("clicked") {champ.activate}
hb.pack_start(b, :expand => false, :fill => false, :padding => 5)
vb.pack_start(hb, :expand => false, :fill => false, :padding => 30)
@label = Gtk::Label.new("")
@label.set_text("On cherche un mot de " + @lettres + " lettres...")
vb.pack_start(@label, :expand => false, :fill => false, :padding => 5)
@label2 = Gtk::Label.new("")
vb.pack_start(@label2, :expand => false, :fill => false, :padding => 5)

window.add(vb)
window.show_all

Gtk.main
exit
