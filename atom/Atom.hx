/*
 * Copyright (c) 2011, Marcus Bergstrom and The haXe Project Contributors
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */
/**
*
* References:
* [1] http://www.atomenabled.org/developers/syndication
* [2] http://diveintomark.org/archives/2004/05/28/howto-atom-id
* [3] http://tools.ietf.org/html/rfc4287#section-4.2.7
*/

/**
TODO
xml.firstChild().toString():
When creating AtomContent/AtomText or anything that can have a type to define it's content. Then we should use xml.firstChild().toString(), 
rather that ..nodeValue to get the data, as we don't want the parser to parse this information.
*/

package atom;
#if flash
import flash.utils.Namespace;
#end

typedef AtomNS = {
	var uri:String;
	var localName:String;
}

class AtomCategoryDocument {

	public var scheme(default,null):String;
	public var fixed(default,null):Bool;
	var categories:Array<AtomCategory>;

	public function new(fixed:Bool=false) {
		this.fixed = fixed;
		categories = new Array();
	}

	public function setScheme(schemeUri:String):Void {
		scheme = schemeUri;
	}

	public function addCategory(atomCategory:AtomCategory):Void {
		categories.push(atomCategory);
	}

	// SERIALIZATION.
	public function toXML(addPrologsAndNamespaces:Bool=true):Xml {
		var xml:Xml = Xml.createDocument();
		var doc:Xml = Xml.createElement("categories");
		if (addPrologsAndNamespaces) {
//			xml.addChild(Xml.createProlog(Atom.XML_PROLOG));
			doc.set('xmlns', AppAtomExtension.NS.uri);
			doc.set('xmlns:'+Atom.NS_ATOM_PREFIX, Atom.NS_ATOM);
		}
		if (fixed) doc.set("fixed", "yes");
		if (scheme != null && scheme != "") doc.set("scheme", scheme);
		xml.addChild(doc);

		// CATEGORIES
		if (categories != null) {
			for (cat in categories) {
				var x:Xml = Xml.createElement("atom:category");
				x.set("term", cat.term);
				if (cat.label != "") x.set("label", cat.label);
				// Scheme is inherited from the the document, if there is a missing scheme or if the scheme is the same.
				// It means we will not show it if that's the case.
				if (cat.scheme != "" && cat.scheme != scheme) x.set("scheme", cat.scheme);
				doc.addChild(x);
			}
		}	
		return xml;
	}

}

class AtomFeed {
	private static inline var GENERATOR_NAME:String = "HaxeAtomGenerator";
	private static inline var GENERATOR_VERSION:String = "0.1";
	private static inline var GENERATOR_URI:String = "https://github.com/mquickform/HaxeAtom";
	public var atom(default,null):Atom;
	public var entries(default,null):Array<AtomEntry>;
	// Pagination.
	public var nextLink(default,null):AtomLink;
	public var previousLink(default,null):AtomLink;
	public var firstLink(default,null):AtomLink;
	public var lastLink(default,null):AtomLink;

	public function new() {
		atom = new Atom();
	}

	public function addEntry(entry:AtomEntry):Void {
		if (entries == null) entries = new Array();
		entries.push(entry);
	}

	public function addExtension(ext:IAtomExtension):Void {
		atom.addExtension(ext);
	}

	// REQUIRED elements of <feed>

	/*
	Identifies the feed using a universally unique and permanent URI. If you have a long-term, 
	renewable lease on your Internet domain name, then you can feel free to use your website's address.
	*/
	public function setId(id:String):Void {
		atom.setId(id);
	}

	/*
	Contains a human readable title for the feed. Often the same as the title of the associated website. 
	This value should not be blank.
	*/
	public function setTitle(atomText:AtomText):Void {
		atom.setTitle(atomText);
	}
	// Helper Methods.
	public function setTitleInText(str:String):Void {
		atom.setTitle(new AtomText(str, AtomText.TEXT));
	}
	public function setTitleInHTML(str:String):Void {
		atom.setTitle(new AtomText(str, AtomText.HTML));
	}
	public function setTitleInXHTML(str:String):Void {
		atom.setTitle(new AtomText(str, AtomText.XHTML));
	}	

	/*
	Indicates the last time the feed was modified in a significant way.
	*/
	public function setUpdated(atomDate:AtomDate):Void {
		atom.setUpdated(atomDate);
	}


	// RECOMMENDED elements of <feed>

	/*
	Names one author of the feed. A feed may have multiple author elements. A feed must contain at least 
	one author element unless all of the entry elements contain at least one author element. 
	*/
	public function addAuthor(person:AtomPerson):Void {
		atom.addAuthor(person);
	}

	/*
	Identifies a related Web page. The type of relation is defined by the rel attribute. A feed is limited 
	to one alternate per type and hreflang. A feed should contain a link back to the feed itself.
	*/
	public function addLink(link:AtomLink):Void {
		atom.addLink(link);
	}


	// OPTIONAL elements of <feed>

	/*
	Specifies a category that the feed belongs to. A feed may have multiple category elements.
	*/
	public function addCategory(category:AtomCategory):Void {
		atom.addCategory(category);
	}

	/*
	Names one contributor to the feed. An feed may have multiple contributor elements.
	*/
	public function addContributor(person:AtomPerson):Void {
		atom.addContributor(person);
	}

	/*
	Identifies the software used to generate the feed, for debugging and other purposes. 
	Both the uri and version attributes are optional.
	*/
	public function setGenerator(name:String, uri:String="", version:String=""):Void {
		atom.setGenerator(name, uri, version);
	}

	/*
	Identifies a small image which provides iconic visual identification for the feed. Icons should be square.
	<icon>/icon.jpg</icon>
	*/
	public function setIcon(uri:String):Void {
		atom.setIcon(uri);
	}	

	/*
	Identifies a larger image which provides visual identification for the feed. Images should be twice as wide as they are tall.
	<logo>/logo.jpg</logo>
	*/
	public function setLogo(uri:String):Void {
		atom.setLogo(uri);
	}

	/*
	Conveys information about rights, e.g. copyrights, held in and over the feed.
	*/
	public function setRights(atomText:AtomText):Void {
		atom.setRights(atomText);
	}
	// Helper Methods.
	public function setRightsInText(str:String):Void {
		atom.setRights(new AtomText(str, AtomText.TEXT));
	}
	public function setRightsInHTML(str:String):Void {
		atom.setRights(new AtomText(str, AtomText.HTML));
	}
	public function setRightsInXHTML(str:String):Void {
		atom.setRights(new AtomText(str, AtomText.XHTML));
	}	

	/*
	Contains a human-readable description or subtitle for the feed.
	*/
	public function setSubtitle(atomText:AtomText):Void {
		atom.setSubtitle(atomText);
	}
	// Helper Methods.
	public function setSubtitleInText(str:String):Void {
		atom.setSubtitle(new AtomText(str, AtomText.TEXT));
	}
	public function setSubtitleInHTML(str:String):Void {
		atom.setSubtitle(new AtomText(str, AtomText.HTML));
	}
	public function setSubtitleInXHTML(str:String):Void {
		atom.setSubtitle(new AtomText(str, AtomText.XHTML));
	}

	/*
	Partial List functionality.
	*/
	public function setFirstLink(href:String):Void {
		firstLink = new AtomLink(href, AtomLink.FIRST);
	}
	public function setNextLink(href:String):Void {
		nextLink = new AtomLink(href, AtomLink.NEXT);
	}
	public function setPreviousLink(href:String):Void {
		previousLink = new AtomLink(href, AtomLink.PREVIOUS);
	}
	public function setLastLink(href:String):Void {
		lastLink = new AtomLink(href, AtomLink.LAST);
	}
	// Helper Method.
	public function addSelfAndPagingLinks(page:Int, pages:Int, baseUrl:String, useParam:String):Void {
		var paramString:String = (baseUrl.indexOf("?") == -1) ? "?"+useParam+"=" : "&amp;"+useParam+"=";
		if (pages > 1) {
			// Self.
			addLink(new AtomLink((page == 1) ? baseUrl : baseUrl+paramString+Std.string(page), AtomLink.SELF));
			// First.
			setFirstLink(baseUrl);
			// Last.
			setLastLink(baseUrl+paramString+Std.string(pages));
			// Next.
			if (page < pages)
				setNextLink(baseUrl+paramString+Std.string(page+1));
			// Previous.
			if (page > 1)
				setPreviousLink((page == 2) ? baseUrl : baseUrl+paramString+Std.string(page-1));
		} else {
			// Self.
			addLink(new AtomLink(baseUrl, AtomLink.SELF));
		}
	}

	// SERIALIZATION.
	public function toXML(addPrologsAndNamespaces:Bool=true):Xml {
		var xml:Xml = Xml.createDocument();
		var feed:Xml = Xml.createElement("feed");
		if (addPrologsAndNamespaces) {
//			xml.addChild(Xml.createProlog(Atom.XML_PROLOG));
			var arr:Array<String> = new Array();
			feed.set('xmlns', Atom.NS_ATOM);
			for (ext in atom.extensions) 
				feed.set("xmlns:"+ext.getNamespace().localName, ext.getNamespace().uri);
		}
		xml.addChild(feed);


		// PAGINATION (OPTIONAL)
		if (firstLink != null)
			feed.addChild(firstLink.serializeToXml());
		if (previousLink != null)
			feed.addChild(previousLink.serializeToXml());
		if (nextLink != null)
			feed.addChild(nextLink.serializeToXml());
		if (lastLink != null)
			feed.addChild(lastLink.serializeToXml());


		// REQUIRED
		// <id>
		if (atom.id == null || atom.id == "") throw("Missing Atom.id");
		var x_id = Xml.createElement("id");
		x_id.addChild(Xml.createPCData(atom.id));
		feed.addChild(x_id);

		// <title>
		if (atom.title == null) throw("Missing Atom.title");
		feed.addChild(atom.title.serializeToXmlWithElementName("title"));

		// <updated>
		if (atom.updated == null) throw("Missing Atom.updated");
		var x_updated = Xml.createElement("updated");
		x_updated.addChild(Xml.createPCData(atom.updated.toString()));
		feed.addChild(x_updated);


		// RECOMMENDED
		// <author>
		if (atom.authors != null) {
			for (author in atom.authors)
				feed.addChild(author.serializeToXmlWithElementName("author"));
		}

		// <link>
		if (atom.links != null) {
			for (link in atom.links)
				feed.addChild(link.serializeToXml());
		}


		// OPTIONAL
		// <category>
		if (atom.categories != null) {
			for (category in atom.categories)
				feed.addChild(category.serializeToXml());
		}

		// <contributor>
		if (atom.contributors != null) {
			for (contributor in atom.contributors)
				feed.addChild(contributor.serializeToXmlWithElementName("contributor"));
		}

		// <generator>
		if (atom.generator == null) {
			setGenerator(GENERATOR_NAME, GENERATOR_URI, GENERATOR_VERSION);
		}
		feed.addChild(atom.generator.serializeToXml());

		// <icon>
		if (atom.icon != null && atom.icon != "") {
			var x_icon = Xml.createElement("icon");
			x_icon.addChild(Xml.createPCData(atom.icon));
			feed.addChild(x_icon);
		}

		// <logo>		
		if (atom.logo != null && atom.logo != "") {
			var x_logo = Xml.createElement("logo");
			x_logo.addChild(Xml.createPCData(atom.logo));
			feed.addChild(x_logo);
		}

		// <rights>
		if (atom.rights != null)
			feed.addChild(atom.rights.serializeToXmlWithElementName("rights"));

		// <subtitle>
		if (atom.subtitle != null) 
			feed.addChild(atom.title.serializeToXmlWithElementName("subtitle"));


		// ENTRIES
		if (entries != null) {
			for (entry in entries) 
				feed.addChild(entry.toXML(false));
		}

		if (atom.extensions != null)
			for (ext in atom.extensions) ext.extend(feed);

		return xml;
	}


	public static function parseXmlFromString(xmlString:String):AtomFeed {
		var feed = new AtomFeed();
		var xml = Xml.parse(xmlString);

		for (child in xml.firstElement().elements()) {
			switch(child.nodeName) {
				case "id":
					feed.setId(child.firstChild().nodeValue);
				case "icon":
					feed.setIcon(child.firstChild().nodeValue);
				case "logo":
					feed.setLogo(child.firstChild().nodeValue);
				case "updated":
					var d:AtomDate = AtomDate.fromString(child.firstChild().nodeValue);
					feed.setUpdated(d);

				case "title":
					feed.setTitle(AtomText.createFromXml(child));
				case "subtitle":
					feed.setSubtitle(AtomText.createFromXml(child));
				case "rights":
					feed.setRights(AtomText.createFromXml(child));

				case "author":
					feed.addAuthor(AtomPerson.createFromXml(child));
				case "contributor":
					feed.addContributor(AtomPerson.createFromXml(child));

				case "generator":
					var gen:AtomGenerator = AtomGenerator.createFromXml(child);
					feed.setGenerator(gen.name, gen.uri, gen.version);

				case "category":
					feed.addCategory(AtomCategory.createFromXml(child));

				case "entry":
					feed.addEntry(AtomEntry.createFromXml(child));

				case "link":
					if (child.exists("rel")) {
						switch(child.get("rel")) {
							case "first":
								feed.setFirstLink(child.get("href"));
							case "next":
								feed.setNextLink(child.get("href"));
							case "previous":
								feed.setPreviousLink(child.get("href"));
							case "last":
								feed.setLastLink(child.get("href"));
						}
					}
					feed.addLink(AtomLink.createFromXml(child));						
			}	
		}
		return feed;
	}
}

class AtomEntry {

	public var atom(default,null):Atom;
	public var id(getId,null):String;
	public var title(getTitle,null):AtomText;
	public var content(getContent,null):AtomContent;

	public function new() {
		atom = new Atom();
	}

	public function addExtension(ext:IAtomExtension):Void {
		atom.addExtension(ext);
	}

	// REQUIRED Elements of <entry>

	/*
	Identifies the entry using a universally unique and permanent URI. Suggestions on how to 
	make a good id can be found here[2]. Two entries in a feed can have the same value for id 
	if they represent the same entry at different points in time.
	*/
	public function setId(id:String):Void {
		atom.setId(id);
	}
	public function getId():String {
		return atom.id;
	}
	/*
	Contains a human readable title for the entry. This value should not be blank.
	<title>Atom-Powered Robots Run Amok</title>
	*/
	public function setTitle(atomText:AtomText):Void {
		atom.setTitle(atomText);
	}
	public function getTitle():AtomText {
		return atom.title;
	}
	// Helper Methods.
	public function setTitleInText(str:String):Void {
		atom.setTitle(new AtomText(str, AtomText.TEXT));
	}
	public function setTitleInHTML(str:String):Void {
		atom.setTitle(new AtomText(str, AtomText.HTML));
	}
	public function setTitleInXHTML(str:String):Void {
		atom.setTitle(new AtomText(str, AtomText.XHTML));
	}	

	/*
	Indicates the last time the entry was modified in a significant way. This value need not 
	change after a typo is fixed, only after a substantial modification. Generally, different 
	entries in a feed will have different updated timestamps.
	<updated>2003-12-13T18:30:02-05:00</updated>
	or <updated>2003-12-13T18:30:02Z</updated> for Zulu time.
	*/
	public function setUpdated(atomDate:AtomDate):Void {
		atom.setUpdated(atomDate);
	}




	// RECOMMENDED elements of <entry>

	/*
	Names one author of the entry. An entry may have multiple authors. An entry must contain at 
	least one author element unless there is an author element in the enclosing feed, or there 
	is an author element in the enclosed source element.
	*/
	public function addAuthor(person:AtomPerson):Void {
		atom.addAuthor(person);
	}

	/*
	Contains or links to the complete content of the entry. Content must be provided if there is 
	no alternate link, and should be provided if there is no summary.
	<content>complete story here</content>
	*/
	public function setContent(atomContent:AtomContent):Void {
		atom.setContent(atomContent);
	}
	public function getContent():AtomContent {
		return atom.content;
	}
	// Helper Methods.
	public function setContentInText(str:String):Void {
		atom.setContent(new AtomContent(str, AtomContent.TEXT));
	}
	public function setContentInHTML(str:String):Void {
		atom.setContent(new AtomContent(str, AtomContent.HTML));
	}
	public function setContentInXHTML(str:String):Void {
		atom.setContent(new AtomContent(str, AtomContent.XHTML));
	}	
	/*
	Identifies a related Web page. The type of relation is defined by the rel attribute. 
	An entry is limited to one alternate per type and hreflang. An entry must contain an 
	alternate link if there is no content element.
	<link rel="alternate" href="/blog/1234"/>
	*/
	public function addLink(link:AtomLink):Void {
		atom.addLink(link);
	}

	/*
	Conveys a short summary, abstract, or excerpt of the entry. Summary should be provided if 
	there either is no content provided for the entry, or that content is not inline 
	(i.e., contains a src attribute), or if the content is encoded in base64. 
	<summary>Some text.</summary>
	*/
	public function setSummary(atomText:AtomText):Void {
		atom.setSummary(atomText);
	}
	// Helper Methods.
	public function setSummaryInText(str:String):Void {
		atom.setSummary(new AtomText(str, AtomText.TEXT));
	}
	public function setSummaryInHTML(str:String):Void {
		atom.setSummary(new AtomText(str, AtomText.HTML));
	}
	public function setSummaryInXHTML(str:String):Void {
		atom.setSummary(new AtomText(str, AtomText.XHTML));
	}	

	// OPTIONAL elements of <entry>

	/*
	Specifies a category that the entry belongs to. A entry may have multiple category elements.
	<category term="technology"/>
	*/
	public function addCategory(category:AtomCategory):Void {
		atom.addCategory(category);
	}

	/*
	Names one contributor to the entry. An entry may have multiple contributor elements. 
	<contributor>
	  <name>Jane Doe</name>
	</contributor>
	*/
	public function addContributor(person:AtomPerson):Void {
		atom.addContributor(person);
	}

	/*
	Contains the time of the initial creation or first availability of the entry.
	<published>2003-12-13T09:17:51-08:00</published>
	*/
	public function setPublished(atomDate:AtomDate):Void {
		atom.setPublished(atomDate);
	}

	/*
	If an entry is copied from one feed into another feed, then the source feed's metadata 
	(all child elements of feed other than the entry elements) should be preserved if the 
	source feed contains any of the child elements author, contributor, rights, or category 
	and those child elements are not present in the source entry.
	<source>
	  <id>http://example.org/</id>
	  <title>Fourty-Two</title>
	  <updated>2003-12-13T18:30:02Z</updated>
	  <rights>© 2005 Example, Inc.</rights>
	</source>
	*/
	public function setSource():Void {
		atom.setSource();
	}

	/*
	Conveys information about rights, e.g. copyrights, held in and over the entry. More info here.
	<rights type="html">
	  &amp;copy; 2005 John Doe
	</rights>
	*/
	public function setRights(atomText:AtomText):Void {
		atom.setRights(atomText);
	}
	// Helper Methods.
	public function setRightsInText(str:String):Void {
		atom.setRights(new AtomText(str, AtomText.TEXT));
	}
	public function setRightsInHTML(str:String):Void {
		atom.setRights(new AtomText(str, AtomText.HTML));
	}
	public function setRightsInXHTML(str:String):Void {
		atom.setRights(new AtomText(str, AtomText.XHTML));
	}	

	public function toXMLString(addPrologsAndNamespaces:Bool=true):String {
		var buf:StringBuf = new StringBuf();
		if (addPrologsAndNamespaces) {
			buf.add('<entry xmlns="'+Atom.NS_ATOM+'"');
			for (ext in atom.extensions) {
				buf.add(' xmlns:'+ext.getNamespace().localName+'="'+ext.getNamespace().uri+'"');
			}
			buf.add(">");
		} else {
			buf.add("<entry>");
		}
		
		// <id>
		if (atom.id == null || atom.id == "") throw("Missing Atom.id");
		buf.add("<id>");
		buf.add(atom.id);
		buf.add("</id>");

		// <title>
		if (atom.title == null) throw("Missing Atom.title");
		buf.add(atom.title.toXMLString("title"));

		// <updated>
		if (atom.updated == null) throw("Missing Atom.updated");
		buf.add("<updated>");
		buf.add(atom.updated.toString());
		buf.add("</updated>");

		// RECOMMENDED.
		// <published>
		if (atom.published != null) {
			buf.add("<published>");
			buf.add(atom.published.toString());
			buf.add("</published>");
		}

		// <author>
		if (atom.authors != null) {
			for (author in atom.authors)
				buf.add(author.toXMLString("author"));
		}

		// <content>
		if (atom.content != null)
			buf.add(atom.content.toXMLString());

		// <summary>
		if (atom.summary != null)
			buf.add(atom.summary.toXMLString("summary"));

		// <link>
		if (atom.links != null) {
			for (link in atom.links)
				buf.add(link.toXMLString());
		}


		// OPTIONAL.
		// <contributor>
		if (atom.contributors != null) {
			for (contributor in atom.contributors)
				buf.add(contributor.toXMLString("contributor"));
		}

		// <rights>
		if (atom.rights != null)
			buf.add(atom.rights.toXMLString("rights"));

		// <category>
		if (atom.categories != null) {
			for (category in atom.categories)
				buf.add(category.toXMLString());
		}

		// EXTENSIONS.
		if (atom.extensions != null)
			for (ext in atom.extensions) ext.toXMLString(buf, addPrologsAndNamespaces);

		// Close.
		buf.add("</entry>");

		return buf.toString();
	}

	// SERIALIZATION.
	public function toXML(addPrologsAndNamespaces:Bool=true):Xml {
		var xml:Xml = null;
		var entry:Xml = null;
		if (addPrologsAndNamespaces) {
			var arr:Array<String> = new Array();
			arr.push('xmlns="'+Atom.NS_ATOM+'"');
			for (ext in atom.extensions) arr.push("xmlns:"+ext.getNamespace().localName+"='"+ext.getNamespace().uri+"'");
			xml = Xml.createDocument();
			entry = Xml.parse('<entry '+arr.join(" ")+'/>').firstChild();
			xml.addChild(entry);
		} else {
			xml = Xml.parse("<entry/>");
			entry = xml.firstElement();
		}


		// REQUIRED.
		// <id>
		if (atom.id == null || atom.id == "") throw("Missing Atom.id");
		var x_id = Xml.createElement("id");
		x_id.addChild(Xml.createPCData(atom.id));
		entry.addChild(x_id);

		// <title>
		if (atom.title == null) throw("Missing Atom.title");
		entry.addChild(atom.title.serializeToXmlWithElementName("title"));

		// <updated>
		if (atom.updated == null) throw("Missing Atom.updated");
		var x_updated = Xml.createElement("updated");
		x_updated.addChild(Xml.createPCData (atom.updated.toString()));
		entry.addChild(x_updated);


		// RECOMMENDED.
		// <published>
		if (atom.published != null) {
			var x_published = Xml.createElement("published");
			x_published.addChild(Xml.createPCData(atom.published.toString()));
			entry.addChild(x_published);
		}

		// <author>
		if (atom.authors != null) {
			for (author in atom.authors)
				entry.addChild(author.serializeToXmlWithElementName("author"));
		}

		// <content>
		if (atom.content != null)
			entry.addChild(atom.content.serializeToXml());		

		// <summary>
		if (atom.summary != null)
			entry.addChild(atom.summary.serializeToXmlWithElementName("summary"));

		// <link>
		if (atom.links != null) {
			for (link in atom.links)
				entry.addChild(link.serializeToXml());
		}


		// OPTIONAL.
		// <contributor>
		if (atom.contributors != null) {
			for (contributor in atom.contributors)
				entry.addChild(contributor.serializeToXmlWithElementName("contributor"));
		}

		// <rights>
		if (atom.rights != null)
			entry.addChild(atom.rights.serializeToXmlWithElementName("rights"));

		// <category>
		if (atom.categories != null) {
			for (category in atom.categories)
				entry.addChild(category.serializeToXml());
		}


		// EXTENSIONS.
		if (atom.extensions != null)
			for (ext in atom.extensions) ext.extend(entry, addPrologsAndNamespaces);

		return xml;
	}

	public static function parseXmlFromString(xmlString:String):AtomEntry {
		var xml = Xml.parse(xmlString);
		return AtomEntry.createFromXml(xml.firstElement());
	}

	public static function createFromXml(x:Xml):AtomEntry {
		var entry:AtomEntry = new AtomEntry();

		for (child in x.elements()) {
			switch(child.nodeName) {
				case "id":
					entry.setId(child.firstChild().nodeValue);
				case "updated":
					var d:AtomDate = AtomDate.fromString(child.firstChild().nodeValue);
					entry.setUpdated(d);
				case "published":
					var d:AtomDate = AtomDate.fromString(child.firstChild().nodeValue);
					entry.setPublished(d);

				case "title":
					entry.setTitle(AtomText.createFromXml(child));
				case "rights":
					entry.setRights(AtomText.createFromXml(child));

				case "author":
					entry.addAuthor(AtomPerson.createFromXml(child));
				case "contributor":
					entry.addContributor(AtomPerson.createFromXml(child));

				// case "source":					
				case "category":
					entry.addCategory(AtomCategory.createFromXml(child));					
				case "link":
					entry.addLink(AtomLink.createFromXml(child));

				case "summary":
					entry.setSummary(AtomText.createFromXml(child));
				case "content":
					entry.setContent(AtomContent.createFromXml(child));
			}	
		}

		return entry;
	}
}

class Atom {

	public static inline var XML_PROLOG:String = 'xml version="1.0" encoding="utf-8"';
	public static inline var NS_ATOM_PREFIX:String = "atom";
	public static inline var NS_ATOM:String = 'http://www.w3.org/2005/Atom';
	public var id(default,null):String;
	public var title(default,null):AtomText;
	public var updated(default,null):AtomDate;
	public var published(default,null):AtomDate;
	public var authors(default,null):Array<AtomPerson>;
	public var contributors(default,null):Array<AtomPerson>;
	public var content(default,null):AtomContent;
	public var summary(default,null):AtomText;
	public var links(default,null):Array<AtomLink>;
	public var categories(default,null):Array<AtomCategory>;
	public var rights(default,null):AtomText;
	public var generator(default,null):AtomGenerator;
	public var icon(default,null):String;
	public var logo(default,null):String;
	public var subtitle(default,null):AtomText;
	public var extensions(default,null):Array<IAtomExtension>;

	public function new() {
		extensions = new Array();
		authors = new Array();
		contributors = new Array();
		links = new Array();
		categories = new Array();
	}

	public static function createElementWithNamespace(elementName:String, ?ns:AtomNS):Xml {
		if (ns == null) {
			var x:Xml = Xml.createElement(elementName);
			return x;
		}

		#if flash9
		var x:Xml = Xml.parse("<"+ns.localName+":"+elementName+" xmlns:"+ns.localName+"='"+ns.uri+"'/>").firstChild();
		#else
		var x:Xml = Xml.parse("<"+ns.localName+":"+elementName+"/>").firstChild();
		#end
		return x;
	}


	public function addExtension(ext:IAtomExtension):Void {
		if (extensions == null) extensions = new Array();
		extensions.push(ext);
	}

	/*
	Identifies the entry using a universally unique and permanent URI. Suggestions on how to 
	make a good id can be found here[1]. Two entries in a feed can have the same value for id 
	if they represent the same entry at different points in time.
	<id>http://example.com/blog/1234</id>
	*/
	public function setId(id:String):Void {
		this.id = id;
	}

	/*
	Contains a human readable title for the entry. This value should not be blank.
	<title>Atom-Powered Robots Run Amok</title>
	*/
	public function setTitle(atomText:AtomText):Void {
		this.title = atomText;
	}

	/*
	Indicates the last time the entry was modified in a significant way. This value need not 
	change after a typo is fixed, only after a substantial modification. Generally, different 
	entries in a feed will have different updated timestamps.
	<updated>2003-12-13T18:30:02-05:00</updated>
	or <updated>2003-12-13T18:30:02Z</updated> for Zulu time.
	*/
	public function setUpdated(atomDate:AtomDate):Void {
		this.updated = atomDate;
	}


	/*
	Names one author of the entry. An entry may have multiple authors. An entry must contain at 
	least one author element unless there is an author element in the enclosing feed, or there 
	is an author element in the enclosed source element.
	<author>
	  <name>John Doe</name>
	</author>

	<author> and <contributor> describe a person, corporation, or similar entity. It has one required element, name, and two optional elements: uri, email.
	<name> conveys a human-readable name for the person.
	<uri> contains a home page for the person.
	<email> contains an email address for the person.	
	*/
	public function addAuthor(person:AtomPerson):Void {
		if (this.authors == null) this.authors = new Array();
		this.authors.push(person);
	}

	/*
	Contains or links to the complete content of the entry. Content must be provided if there is 
	no alternate link, and should be provided if there is no summary.
	<content>complete story here</content>

	<content> either contains, or links to, the complete content of the entry.
	In the most common case, the type attribute is either text, html, xhtml, in which case the 
	content element is defined identically to other text constructs:
	- Otherwise, if the src attribute is present, it represents the URI of where the content can be 
	found. The type attribute, if present, is the media type of the content.
	- Otherwise, if the type attribute ends in +xml or /xml, then an xml document of this type is 
	contained inline.
	- Otherwise, if the type attribute starts with text, then an escaped document of this type 
	is contained inline.
	- Otherwise, a base64 encoded document of the indicated media type is contained inline.
	*/
	public function setContent(atomContent:AtomContent):Void {
		this.content = atomContent;
	}

	/*
	Identifies a related Web page. The type of relation is defined by the rel attribute. 
	An entry is limited to one alternate per type and hreflang. An entry must contain an 
	alternate link if there is no content element.
	<link rel="alternate" href="/blog/1234"/>

	<link> is patterned after html's link element. It has one required attribute, href, and five 
	optional attributes: rel, type, hreflang, title, and length.
	@href is the URI of the referenced resource (typically a Web page)
	@rel contains a single link relationship type. It can be a full URI (see extensibility), or one 
	of the following predefined values (default=alternate):
		- 	alternate: an alternate representation of the entry or feed, for example a permalink 
			to the html version of the entry, or the front page of the weblog.
		- 	enclosure: a related resource which is potentially large in size and might require 
			special handling, for example an audio or video recording.
		-	related: an document related to the entry or feed.
		-	self: the feed itself.
		-	via: the source of the information provided in the entry.	
	@type indicates the media type of the resource.
	@hreflang indicates the language of the referenced resource.
	@title human readable information about the link, typically for display purposes.
	@length the length of the resource, in bytes.
	*/
	public function addLink(link:AtomLink):Void {
		if (this.links == null) this.links = new Array();
		this.links.push(link);
	}

	/*
	Conveys a short summary, abstract, or excerpt of the entry. Summary should be provided if 
	there either is no content provided for the entry, or that content is not inline 
	(i.e., contains a src attribute), or if the content is encoded in base64. 
	<summary>Some text.</summary>
	*/
	public function setSummary(atomText:AtomText):Void {
		this.summary = atomText;
	}	

	/*
	Specifies a category that the entry belongs to. A entry may have multiple category elements.
	<category term="technology"/>

	<category> has one required attribute, term, and two optional attributes, scheme and label.
	@term identifies the category
	@scheme identifies the categorization scheme via a URI.
	@label provides a human-readable label for display
	*/
	public function addCategory(category:AtomCategory):Void {
		if (this.categories == null) this.categories = new Array();
		this.categories.push(category);
	}

	/*
	Names one contributor to the entry. An entry may have multiple contributor elements. 
	<contributor>
	  <name>Jane Doe</name>
	</contributor>

	<author> and <contributor> describe a person, corporation, or similar entity. It has one required element, name, and two optional elements: uri, email.
	<name> conveys a human-readable name for the person.
	<uri> contains a home page for the person.
	<email> contains an email address for the person.	
	*/
	public function addContributor(person:AtomPerson):Void {
		if (this.contributors == null) this.contributors = new Array();
		this.contributors.push(person);
	}

	/*
	Contains the time of the initial creation or first availability of the entry.
	<published>2003-12-13T09:17:51-08:00</published>
	*/
	public function setPublished(atomDate:AtomDate):Void {
		this.published = atomDate;
	}

	/*
	If an entry is copied from one feed into another feed, then the source feed's metadata 
	(all child elements of feed other than the entry elements) should be preserved if the 
	source feed contains any of the child elements author, contributor, rights, or category 
	and those child elements are not present in the source entry.
	<source>
	  <id>http://example.org/</id>
	  <title>Fourty-Two</title>
	  <updated>2003-12-13T18:30:02Z</updated>
	  <rights>© 2005 Example, Inc.</rights>
	</source>
	*/
	public function setSource():Void {
		// Not yet implemented due to complexity and unlikeliness of use at this stage.
	}

	/*
	Conveys information about rights, e.g. copyrights, held in and over the entry. More info here.
	<rights type="html">
	  &amp;copy; 2005 John Doe
	</rights>
	*/
	public function setRights(atomText:AtomText):Void {
		this.rights = atomText;
	}	

	/*
	Identifies the software used to generate the feed, for debugging and other purposes. Both the uri 
	and version attributes are optional.
	<generator uri="/myblog.php" version="1.0">
	  Example Toolkit
	</generator>
	*/
	public function setGenerator(name:String, uri:String="", version:String=""):Void {
		this.generator = new AtomGenerator(name, uri, version);
	}

	/*
	Identifies a small image which provides iconic visual identification for the feed. Icons should be square.
	<icon>/icon.jpg</icon>
	*/
	public function setIcon(uri:String):Void {
		this.icon = uri;
	}

	/*
	Identifies a larger image which provides visual identification for the feed. Images should be twice as wide as they are tall.
	<logo>/logo.jpg</logo>
	*/
	public function setLogo(uri:String):Void {
		this.logo = uri;
	}

	public function setSubtitle(atomText:AtomText):Void {
		this.subtitle = atomText;
	}

}

class AtomPerson {

	public var name(default,null):String;
	public var uri(default,null):String;
	public var email(default,null):String;

	public function new(name:String, uri:String="", email:String="") {
		this.name = name;
		this.uri = uri;
		this.email = email;
	}

	public function serializeToXmlWithElementName(elementName:String):Xml {
		var x:Xml = Xml.createElement(elementName);
		var xName:Xml = Xml.createElement("name");
		xName.addChild(Xml.createPCData(name));
		x.addChild(xName);

		if (uri != "") {
			var uriElement = Xml.createElement("uri");
			uriElement.addChild(Xml.createPCData(uri));
			x.addChild(uriElement);
		}

		if (email != "") {
			var emailElement = Xml.createElement("email");
			emailElement.addChild(Xml.createPCData(email));
			x.addChild(emailElement);			
		}

		return x;
	}
	
	public function toXMLString(elementName:String):String {
		var buf:StringBuf = new StringBuf();
		buf.add("<");
		buf.add(elementName);
		buf.add(">");
		
		buf.add("<name>");
		buf.add(name);
		buf.add("</name>");
		
		if (uri != "") {
			buf.add("<uri>");
			buf.add(uri);
			buf.add("</uri>");
		}
		if (email != "") {
			buf.add("<email>");
			buf.add(email);
			buf.add("</email>");
		}

		buf.add("</");
		buf.add(elementName);
		buf.add(">");
		
		return buf.toString();
	}

	public static function createFromXml(x:Xml):AtomPerson {
		if (x.nodeName != "author" && x.nodeName != "contributor")
			throw("Cannot create AtomPerson from xml where node name is not 'category' or 'author'");
		var pName:String = "";
		var pURI:String = "";
		var pEmail:String = "";
		for (n in x.elements()) {
			switch(n.nodeName) {
				case "name":
					pName = n.firstChild().nodeValue;
				case "uri":
					pURI =  n.firstChild().nodeValue;
				case "email":
					pEmail = n.firstChild().nodeValue;
			}
		}
		return new AtomPerson(pName, pURI, pEmail);
	}
}

class AtomCategory {

	public var term(default,null):String;
	public var scheme(default,null):String;
	public var label(default,null):String;

	public function new(term:String, scheme:String="", label:String=""):Void {
		this.term = term;
		this.scheme = scheme;
		this.label = label;
	}

	public function serializeToXml():Xml {
		var x:Xml = Xml.createElement("category");
		x.set("term", term);
		if (scheme != "") x.set("scheme", scheme);
		if (label != "") x.set("label", label);
		return x;
	}
	
	public function toXMLString():String {
		var buf:StringBuf = new StringBuf();
		buf.add('<category term="'+term+'">');
				
		if (scheme != "") {
			buf.add("<scheme>");
			buf.add(scheme);
			buf.add("</scheme>");
		}
		if (label != "") {
			buf.add("<label>");
			buf.add(label);
			buf.add("</label>");
		}

		buf.add("</category>");
		return buf.toString();
	}
	

	public static function createFromXml(x:Xml):AtomCategory {
		if (x.nodeName != "category")
			throw("Cannot create AtomCategory from xml where node name is not 'category'");
		if (!x.exists("term")) throw("AtomCategory requires property 'term'");
		var pTerm:String = x.get("term");
		var pScheme:String = x.exists("scheme") ? x.get("scheme") : "";
		var pLabel:String = x.exists("label") ? x.get("label") : "";		
		return new AtomCategory(pTerm, pScheme, pLabel);
	}
}

class AtomDate {

	/*
		A Date construct is an element whose content MUST conform to the
		"date-time" production in [RFC3339].  In addition, an uppercase "T"
		character MUST be used to separate date and time, and an uppercase
		"Z" character MUST be present in the absence of a numeric time zone
		offset.

		<updated>2003-12-13T18:30:02Z</updated>
		<updated>2003-12-13T18:30:02.25Z</updated>
		<updated>2003-12-13T18:30:02.258Z</updated>
		<updated>2003-12-13T18:30:02+01:00</updated>
		<updated>2003-12-13T18:30:02.25+01:00</updated>
	*/

#if neko
	private static var date_get_tz = neko.Lib.load("std","date_get_tz",0);
#end
	public var date(default,null):Date;

	public function new(dateInUTC:Date) {
		date = dateInUTC;
	}

	public static function fromString(atomStr:String):AtomDate {
		var ereg:EReg = ~/^([0-9]{4}-[0-1][0-9]-[0-3][0-9])T([0-2][0-9]:[0-6][0-9]:[0-6][0-9])(?:\.[0-9]{1,3})?((Z)|([+|-]))(?(5)([0-1][0-9]):([0-6][0-9]))$/;
		if (ereg.match(atomStr)) {
			if (ereg.matched(4) == "Z")
				return new AtomDate(Date.fromString(ereg.matched(1)+" "+ereg.matched(2)));

			var dateStr:String = ereg.matched(1);
			var timeStr:String = ereg.matched(2);
			var hoursOffset:Int = Std.parseInt(ereg.matched(6));
			var minutesOffset:Int = Std.parseInt(ereg.matched(7));
			if (ereg.matched(5) == "+") {
				hoursOffset = -hoursOffset;
				minutesOffset = -minutesOffset;
			}
			var d:Date = new Date(
				Std.parseInt(dateStr.substr(0,4)),					// Year 
				Std.parseInt(dateStr.substr(5,2))-1,				// Month
				Std.parseInt(dateStr.substr(8,2)), 					// Date
				Std.parseInt(timeStr.substr(0,2)) + hoursOffset,	// Hour
				Std.parseInt(timeStr.substr(3,2)) + minutesOffset,	// Minutes
				Std.parseInt(timeStr.substr(6,2))					// Seconds.
				);
			return new AtomDate(d);			
		}
		throw("Not an Atom Date");
	}

	public static function now():AtomDate {
#if neko
		var now:Date = Date.now();
		var offset:Int = Math.round(date_get_tz()/3600);
		return new AtomDate(new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours()-offset, now.getMinutes(), now.getSeconds()));
#elseif php
		// !FIXME
		var now:Date = Date.now();
		var offset:Int = Math.round(0/3600);
		return new AtomDate(new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours()-offset, now.getMinutes(), now.getSeconds()));
#elseif flash
		untyped {
			var now = __new__(__global__["Date"]);
			return new AtomDate(new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds()));		
		}
#end		
	}

	public function getUTCDate():Date {
		return date;
	}	

	public function toString():String {
		return StringTools.replace(date.toString(), " ", "T") + "Z";
	}

	public function toDateString():String {
		return date.toString();
	}

}

class AtomLink {
	/* See [3] */
	// Standard.
	public static inline var ALTERNATE:String = "alternate";
	public static inline var ENCLOSURE:String = "enclosure";
	public static inline var RELATED:String = "related";
	public static inline var SELF:String = "self";
	public static inline var VIA:String = "via";
	// Atom Specific.	
	public static inline var EDIT:String = "edit";
	public static inline var EDIT_MEDIA:String = "edit-media";
	public static inline var NEXT:String = "next";
	public static inline var PREVIOUS:String = "previous";
	public static inline var FIRST:String = "first";
	public static inline var LAST:String = "last";

	public var href(default,null):String;
	public var rel(default,null):String;
	public var mediaType(default,null):String;
	public var title(default,null):String;
	public var lang(default,null):String;
	public var length(default,null):String;

	public function new(href:String, rel:String="", mediaType:String="", title:String="", lang:String="", length:String="") {
		this.href = href;
		this.rel = rel;
		this.mediaType = mediaType;
		this.title = title;
		this.lang = lang;
		this.length = length;
	}

	public function serializeToXml():Xml {
		var x:Xml = Xml.createElement("link");
		x.set("href", href);
		if (rel != "") x.set("rel", rel);
		if (mediaType != null && mediaType != "") x.set("type", mediaType);
		if (lang != null && lang != "") x.set("lang", lang);
		if (title != null && title != "") x.set("title", title);
		if (length != null && length != "") x.set("length", length);		
		return x;		
	}
	
	public function toXMLString():String {
		var buf:StringBuf = new StringBuf();
		buf.add('<link href="'+href+'"');

		if (rel != "")
			buf.add(' rel="'+rel+'"');
		if (mediaType != null && mediaType != "")
			buf.add(' type="'+mediaType+'"');
		if (lang != null && lang != "")
			buf.add(' lang="'+lang+'"');
		if (title != null && title != "")
			buf.add(' title="'+title+'"');
		if (length != null && length != "")
			buf.add(' length="'+length+'"');
			
		buf.add("/>");
		return buf.toString();
	}
	

	public static function createFromXml(x:Xml):AtomLink {
		if (x.nodeName != "link")
			throw("Cannot create AtomLink from xml where node name is not 'link'");
		var pHref:String = x.get("href");
		var pRel:String = x.exists("rel") ? x.get("rel") : "";
		var pType:String = x.exists("type") ? x.get("type") : "";
		var pTitle:String = x.exists("title") ? x.get("title") : "";
		var pLang:String = x.exists("lang") ? x.get("lang") : "";
		var pLength:String = x.exists("length") ? x.get("length") : "";		
		return new AtomLink(pHref, pRel, pType, pTitle, pLang, pLength);
	}
}


class AtomText {

	public static inline var TEXT:String = "text";
	public static inline var HTML:String = "html";
	public static inline var XHTML:String = "xhtml";
	public var str(default,null):String;
	public var encodingType:String;

	public function new(str:String, encodingType:String="text") {
		setText(str, encodingType, true);
	}

	public function serializeToXmlWithElementName(elementName:String, ?ns:AtomNS):Xml {
		var x:Xml = Atom.createElementWithNamespace(elementName, ns);
		if (encodingType != "") x.set("type", encodingType);
		x.addChild(Xml.createPCData(str));
		return x;
	}
	
	public function toXMLString(elementName:String, ?ns:AtomNS):String {
		var buf:StringBuf = new StringBuf();
		buf.add('<'+elementName);
		
		if (encodingType != "")
			buf.add(' type="'+encodingType+'"');
		buf.add('>');
		
		buf.add(str);
		buf.add('</');
		buf.add(elementName);
		buf.add(">");
		/*
			TODO 
			- Add namespace.
		*/
		return buf.toString();
	}

	public function setText(str:String, encodingType:String="text", parseEncoding:Bool=true) {		
		this.str = new String(str);
		this.encodingType = encodingType;
		if (parseEncoding) {
			switch(encodingType) {
				case TEXT:
				case HTML:
					this.str = StringTools.htmlEscape(str);
				case XHTML:
					this.str = '<div xmlns="http://www.w3.org/1999/xhtml">'+str+'</div>';
				default:
					throw("Encoding '"+encodingType+"' not supported by AtomText");
			}
		}
	}

	public static function createFromXml(xml:Xml):AtomText {
		var text:AtomText = new AtomText("");

		if (xml.exists("type")) {
			text.setText(xml.firstChild().nodeValue, xml.get("type"), false);
			return text;
		}

		// Must be text.
		return new AtomText(xml.firstChild().nodeValue);		
	}
}

class AtomContent {

	public static inline var TEXT:String = "text";
	public static inline var HTML:String = "html";
	public static inline var XHTML:String = "xhtml";

	public var str(default,null):String;
	public var encodingType:String;
	public var src:String;

	public function new(str:String, encodingType:String="text", src:String="") {
		setContent(str, encodingType, src, true);
	}

	public function setContent(str:String, encodingType:String="text", src:String="", parseEncoding:Bool=true) {	
		this.str = new String(str);
		this.encodingType = encodingType;
		this.src = src;
		if (parseEncoding) {
			switch(encodingType) {
				case TEXT:
				case HTML:
					this.str = StringTools.htmlEscape(str);
				case XHTML:
					this.str = '<div xmlns="http://www.w3.org/1999/xhtml">'+str+'</div>';
			}	
		}
	}

	public function serializeToXml():Xml {
		var x:Xml = Xml.createElement("content");
		if (encodingType != "") x.set("type", encodingType);
		if (src != null && src != "") 
			x.set("src", src);
		else 
			x.addChild(Xml.createPCData(str));
		return x;		
	}
	
	public function toXMLString():String {
		var buf:StringBuf = new StringBuf();
		buf.add('<content');
		
		if (encodingType != "")
			buf.add(' type="'+encodingType+'"');
		if (src != null && src != "") {
			buf.add(' src="'+src+'"');
			buf.add('/>');
			return buf.toString();
		}
		buf.add('>');
		buf.add(str);
		buf.add('</content>');
		return buf.toString();
	}
	
	public static function createFromXml(xml:Xml):AtomContent {
		if (xml.nodeName != "content")
			throw("Cannot create AtomContent from xml where node name is not 'content'");
		var text:AtomContent = new AtomContent("");
		if (xml.exists("type")) {
			if (StringTools.endsWith(xml.get("type"), "xml")) {
				var strBuf:StringBuf = new StringBuf();
				for (a in xml.elements())
					strBuf.add(a.toString());
				text.setContent(strBuf.toString(), xml.get("type"), (xml.exists("src") ? xml.get("src") : ""), false);
			} else {
				text.setContent(xml.firstChild().toString(), xml.get("type"), (xml.exists("src") ? xml.get("src") : ""), false);				
			}
			return text;
		}

		// Must be plain text.
		return new AtomContent(xml.firstChild().nodeValue);
	}
}

class AtomGenerator {
	public var name(default,null):String;
	public var uri(default,null):String;
	public var version(default,null):String;

	public function new(name:String, uri:String="", version:String="") {
		this.name = name;
		this.uri = uri;
		this.version = version;
	}

	public function serializeToXml():Xml {
		var x:Xml = Xml.createElement("generator");
		if (uri != "") x.set("uri", uri);
		if (version != "") x.set("version", version);
		x.addChild(Xml.createPCData(name));
		return x;
	}
	
	public function toXMLString():String {
		var buf:StringBuf = new StringBuf();
		buf.add('<generator');
		
		if (uri != "") buf.add(' uri="'+uri+'"');
		if (version != "") buf.add(' version="'+version+'"');
		buf.add('>');
		buf.add(name);
		buf.add('</generator>');
		return buf.toString();
	}

	public static function createFromXml(x:Xml):AtomGenerator {
		if (x.nodeName != "generator")
			throw("Cannot create AtomGenerator from xml where node name is not 'generator'");
		var pName:String = x.firstChild().nodeValue;
		var pURI:String = x.exists("uri") ? x.get("uri") : "";
		var pVersion:String = x.exists("version") ? x.get("version") : "";
		return new AtomGenerator(pName, pURI, pVersion);
	}
}
