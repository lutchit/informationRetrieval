#!/usr/bin/perl
use strict ;
no strict 'refs';
use XML::LibXML;
use encoding 'utf8';


BEGIN {}


my ($repcoll) = "coll"; # répertoire ne contenant que des fichiers XXXXX.xml
my ($parser) = XML::LibXML->new('recover'=>1);
$parser->recover_silently(1); # pour éviter que le parser plante si erreur XML

# comptages
my ($nb_articles) = 0;
my ($nb_elements) = 0;
my ($taille_texte) = 0;

my %hashwords = ();

# limites
my ($nb_todo) = 1;
my (%balises_ok) = ('bdy'=>1, 'sec'=>1, 'title'=>1);

# on ouvre le répertoire de la collection
opendir(REPIN, $repcoll) || die "Erreur ouverture !\n";
my ($entry);
while ($entry = readdir(REPIN)) {
	print "ENTRY : $entry\n";
    if (! ($entry =~ /^\.\.?$/)) {
	# Si le nom de fichier ne commence pas par ".", c'est donc un fichier XML
	$nb_articles ++;
	if (!($nb_articles % 100)) { # Une trace
	    print "Nombre d'articles : $nb_articles\n";
	}
	# On parse le fichier XML
	my ($tree) = $parser->parse_file( "$repcoll/$entry" );
	if ($tree) {
			#print "treeee -> $tree\n";
	    # on récupère la racine
	    my $root = $tree->getDocumentElement;
	    #print "roooot -> $root\n";
	    if ($root) {
			# on cherche un élément "titre"
			my ($titre) = $root->findvalue('//title');

			$titre =~ s/\s+/ /g;
			$nb_elements ++;
			print "titre : $titre\n";
			# on récupère le numéro de document
			my $nodoc = $root->getElementsByTagName('id')->[0]->getFirstChild->getData;
			print "nodoc : $nodoc\n";


			# for my $sample ($root->findnodes('//bdy')) {
   #  		for my $property ($sample->findnodes('./*')) {
   #      	print $property->nodePath(), " ======> ", $property->textContent(), "\n";
   #  		}
   #  		print "\n";
			# }	

			my $nodes = $root->findnodes('//*');
			foreach my $node ($nodes->get_nodelist) {
					#printf "%s --> %s\n", $node->nodePath, $node->getFirstChild->getData;
					my $nodePath = $node->nodePath;
					my $nodeContent = $node->getFirstChild->getData;

					$nodeContent =~ s/\n/ /sg;
					$nodeContent =~ s/ +/ /sg;
					$nodeContent =~ tr/a-zA-Z0-9 //dc;

					# print "CONTENT =======> $nodeContent\n";

					my @mots = split(" ", $nodeContent);

					foreach my $mot (@mots) {
						if (!exists($hashwords{$mot})) {
							#print "mot1 : $mot\n";
							my %hashtf = ();
							# print "Path : $nodePath\n";
							$hashtf{$nodePath} = 1;
							$hashwords{$mot} = \%hashtf;
						} else {
							#print "mot2 : $mot\n";					
							if (exists($hashwords{$mot}{$nodePath})) {
								$hashwords{$mot}{$nodePath}++;
							}
							else {
								my %hashtf = ();
								$hashtf{$nodePath} = 1;
								$hashwords{$mot} = \%hashtf;
							}
						}
						# print "$mot | ";
						# print "TEST :: $hashwords{$mot}{$nodePath}\n";
					}
			}
			print "\n\n\n";

			#print "$hashwords{is}{\/article\/entity\/bdy\/sec[3]\/p[2]}\n";


			# my $body = $root->findnodes('//bdy');
			# #print "BODY : $body\n\n";
			# #my $nodeB = $body->childNodes();
			# #my ($pathB) = $nodeB->nodePath();
			# #print "PATHB --> $pathB\n";

			# my $n = $root->findnodes('//link')->shift;
			# say $n->nodePath;


			# $body =~ s/\n/ /sg;
			# $body =~ s/ +/ /sg;
			# # $body =~ s/\W+//sg;
			# #$body =~ s/[^\pL\s]//g;
			# $body =~ tr/a-zA-Z0-9 //dc;
			# # $body =~ s/\;//sg;
			# # $body =~ s/\,//sg;
			# # $body =~ s/\'//sg;
			# # $body =~ s/\"//sg;
			# # $body =~ s/\(//sg;
			# # $body =~ s/\)//sg;
			# # $body =~ s/\-//sg;
			# # $body =~ s/\_//sg;
			# # $body =~ s/\^//sg;
			# # $body =~ s/\://sg;
			# # $body =~ s/\///sg;

			# #print "body : $body\n\n";

			# on récupère le texte de tout l'article
			my ($texte) = $root->textContent;

			#chomp($texte);
			#$texte =~ s/\n\n\/\n/g;

			#print "texte : $texte\n";
			#my @mots = split(" ", $body);

			# foreach my $mot (@mots) {
			# 	if (!exists($hashwords{$mot})) {
			# 		#print "mot1 : $mot\n";
			# 		my %hashtf = ();
			# 		$hashtf{$nodoc} = 1;
			# 		$hashwords{$mot} = \%hashtf;
			# 	} else {
			# 		#print "mot2 : $mot\n";					
			# 		$hashwords{$mot}{$nodoc}++;
			# 	}
			# 	#print "$mot | ";
			# }

			my $pathTest = "\/article\/entity\/bdy\/sec[3]\/p[2]";
			print "Nb occurence of 'is' in $pathTest : $hashwords{is}{$pathTest}\n";

			$taille_texte += length($texte);
			my ($chemin) = '/article[1]';
			#print "CHEMIN -> $chemin\n";
			my (%num_balises);
			#print "NUM_BALISES -> $num_balises\n";
			# on parcours les fils de la racine
			foreach my $node ($root->childNodes()) {
				#print "NODE ---> $node\n";
					#my ($path) = $node->nodePath();
					#print "PATH --> $path\n";
			    my ($tag) = $node->nodeName();
			    #print "TAG --> $tag\n";
			    if ($balises_ok{$tag}) {
					$nb_elements ++;
					$num_balises{$tag}++;
					#print "$entry$chemin/$tag\[$num_balises{$tag}\] : $titre\n";
			    }
			}
	    } else {
			print "Erreur title parser (fichier $repcoll/$entry\n";
	    }
	} else {
	    print "Erreur parser (fichier $repcoll/$entry\n";
	}
	last if ($nb_articles == $nb_todo);
    }
}

# foreach my $k (sort keys(%hashwords)) {
# 	print "Clef=$k Valeur=$hashwords{$k}\n";
# }
# print "TEST : $hashwords{the}\n";
# my %hash2 = $hashwords{the};
# print "\n\n";
# foreach my $k (sort keys(%hash2)) {
# 	print "Clef=$k Valeur=$hash2{$k}\n";
# }

print "nb words : ".scalar(keys (%hashwords))."\n";

print "Nombre d'articles : $nb_articles
Nombre d'elements : $nb_elements
Taille totale texte : $taille_texte\n";
