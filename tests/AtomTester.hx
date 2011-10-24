package tests;
import atom.Atom;
import atom.AppAtomExtension;
import haxe.unit.TestRunner;
import haxe.unit.TestCase;

#if flash
class AtomTester extends flash.display.MovieClip {
#else
class AtomTester {
#end

	public function new() {
		#if flash9
		super();
		flash.Lib.current.addChild(this);
		runTests();
		#else
		runTests();
		#end
		
	}
	
	public function runTests():Void {
		var r = new TestRunner();
		r.add(new SimpleTest());
		r.run();		
	}

	public static function main() {
		#if flash9 
		if (haxe.Firebug.detect()) haxe.Firebug.redirectTraces(); 
		#end
		new AtomTester();
	}
	
}

class SimpleTest extends TestCase {
	
	public function testGeneration() {
		var atomEntry:AtomEntry = new AtomEntry();
		atomEntry.setId("123512351235");
		atomEntry.setTitleInText("Hello I am a Title");
		atomEntry.addAuthor(new AtomPerson("Marcus", "", "marcus@quickform.net"));
		atomEntry.setSummaryInText("Summary");
		atomEntry.setUpdated(AtomDate.fromString("2010-01-01T01:01:01Z"));
				
		var app = new AppAtomExtension();
		app.draft = true;
		app.edited = AtomDate.fromString("2011-10-10T13:50:00+01:00");
		atomEntry.addExtension(app);

		assertEquals('<entry xmlns="http://www.w3.org/2005/Atom" xmlns:app="http://www.w3.org/2007/app"><id>123512351235</id><title type="text">Hello I am a Title</title><updated>2010-01-01T01:01:01Z</updated><author><name>Marcus</name><email>marcus@quickform.net</email></author><summary type="text">Summary</summary><app:control><app:draft>yes</app:draft></app:control><app:edited>2011-10-10T12:50:00Z</app:edited></entry>', atomEntry.toXMLString());
	}
	
}