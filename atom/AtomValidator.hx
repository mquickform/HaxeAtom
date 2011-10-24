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

/*
	TODO Add check for html entities in atomText construct.
	TODO Add Service Document validation.
	TODO Add Category Document validation.
	TODO Make it possible to validate with different XMLNS tags.
*/
package atom;
import haxe.xml.Check;

class AtomValidator {

	public static function getAtomDateRule():Rule {
		return RData(FReg(~/^([0-9]{4}-[0-1][0-9]-[0-3][0-9])T([0-2][0-9]:[0-6][0-9]:[0-6][0-9])(?:\.[0-9]{1,3})?((Z)|([+|-]))(?(5)([0-1][0-9]):([0-6][0-9]))$/));
	}

	public static function getAtomPersonRule():Rule {
		return RList([
			RNode("name", [], RData()),
			ROptional(RNode("uri", [], RData())),
			ROptional(RNode("email", [], RData()))
		], false);
	}

	public static function getAtomCategoryRule():Rule {
		return RNode("category", [
			Attrib.Att("term"), 
			Attrib.OptionalAtt("label"),
			Attrib.OptionalAtt("scheme")
		]);
	}

	public static function getAtomGeneratorRule():Rule {
		return RNode("generator", [
			Attrib.Att("name"),
			Attrib.OptionalAtt("uri"),
			Attrib.OptionalAtt("version")
		]);
	}

	public static function getAtomLinkRule():Rule {
		return RNode("link", [
			Attrib.Att("href"),
			Attrib.OptionalAtt("rel"),
			// lang tag according to rfc3066
			Attrib.OptionalAtt("type"),
			Attrib.OptionalAtt("lang", FReg(~/^[a-z]{1,8}(\-[a-z0-9]{1,8})?$/i)),
			Attrib.OptionalAtt("title"),
			Attrib.OptionalAtt("length", FInt)
		]);
	}

	public static function getAtomTextRule(withTagName:String):Rule {
		var a = RNode(withTagName, [Attrib.Att("type", FEnum(["text"]), "text")], RData() );
		var b = RNode(withTagName, [Attrib.Att("type", FEnum(["html"]))], RData() );
		var c = RNode(withTagName, [Attrib.Att("type", FEnum(["xhtml"]))], 
			RNode("div", [Attrib.Att("xmlns", FEnum(["http://www.w3.org/1999/xhtml"]))], RAnyContent)
		);	
		return RChoice([a,b,c]);		
	}

	public static function getAtomContentRule(withTagName:String):Rule {
		// If the value of "type" begins with "text/" (case insensitive),
       	// the content of atom:content MUST NOT contain child elements.
		var a = RNode(withTagName, [Attrib.Att("type", FReg(~/^text(\/)?/i), "text")], RData() );
		var b = RNode(withTagName, [Attrib.Att("type", FEnum(["html"]))], RData() );
		var c = RNode(withTagName, [Attrib.Att("type", FEnum(["xhtml"]))], 
			RNode("div", [Attrib.Att("xmlns", FEnum(["http://www.w3.org/1999/xhtml"]))], RAnyContent)
		);
		// If the value of "type" is an XML media type [RFC3023] or ends
		// with "+xml" or "/xml" (case insensitive), the content of
		// atom:content MAY include child elements and SHOULD be suitable
		// for handling as the indicated media type.  If the "src" attribute
		// is not provided, this would normally mean that the "atom:content"
		// element would contain a single child element that would serve as
		// the root element of the XML document of the indicated type.
		var d = RNode(withTagName, [Attrib.Att("type", FReg(~/[+|\/]xml$/i)), Attrib.OptionalAtt("src")], RAnyContent);
		var e = RNode(withTagName, [Attrib.Att("type"), Attrib.OptionalAtt("src")]);
		// For all other values of "type", the content of atom:content MUST
		// be a valid Base64 encoding, as described in [RFC3548], section 3.
		// When decoded, it SHOULD be suitable for handling as the indicated
		// media type.  In this case, the characters in the Base64 encoding
		// MAY be preceded and followed in the atom:content element by white
		// space, and lines are separated by a single newline (U+000A)
		// character.		
		var f = RNode(withTagName, [Attrib.Att("type")], RData(FReg(~/[a-z0-9\+\/=\n ]*/gi)));
		return RChoice([a,b,c,d,e,f]);
	}

	public static function getNamespaceRuleAsDefault():Attrib {
		return Attrib.Att("xmlns", FEnum(["http://www.w3.org/2005/Atom"]));
	}
	public static function getNamespaceRule():Attrib {
		return Attrib.Att("xmlns:atom", FEnum(["http://www.w3.org/2005/Atom"]));
	}
	public static function getFeedRules():Array<Rule> {
		return [
			// author(s)
			RMulti(RNode("author", [], getAtomPersonRule()), true),
			// categor(y|ies)
			RMulti(getAtomCategoryRule(), false),
			// contributor(s)
			RMulti(RNode("contributor", [], getAtomPersonRule()), false),
			// generator
			ROptional(getAtomGeneratorRule()),
			// icon
			ROptional(RNode("icon", [], RData())),
			// id
			RNode("id", [], RData()),
			// link(s)
			RMulti(getAtomLinkRule(), false),
			// logo
			ROptional(RNode("logo", [], RData())),
			// rights
			ROptional(getAtomTextRule("rights")),
			// subtitle
			ROptional(getAtomTextRule("subtitle")),
			// title
			getAtomTextRule("title"),
			// updated
			ROptional(RNode("updated", [], getAtomDateRule()))
			// NOTE! entry will have to be constructed and added manually.
		];
	}
	public static function getEntryRules():Array<Rule> {
		return [
			// author(s)
			RMulti(RNode("author", [], getAtomPersonRule()), true),
			// categor(y|ies)
			RMulti(getAtomCategoryRule(), false),
			// content
			getAtomContentRule("content"),
			// contributor(s)
			RMulti(RNode("contributor", [], getAtomPersonRule()), false),
			// id
			RNode("id", [], RData()),
			// link(s)
			RMulti(getAtomLinkRule(), false),
			// published
			ROptional(RNode("published", [], getAtomDateRule())),
			// rights
			ROptional(getAtomTextRule("rights")),
			// source
			/*
				TODO Implement "source" check
			*/
			// summary.
			ROptional(getAtomTextRule("summary")),
			// title
			getAtomTextRule("title"),
			// updated
			ROptional(RNode("updated", [], getAtomDateRule()))
		];		
	}

	public static function validateDocumentAsString(doc:String, r:Rule) {
		validateDocument(Xml.parse(doc), r);
	}
	public static function validateDocument(doc:Xml, r:Rule) {
		XMLCheck.checkDocument(doc, r);
	}
}

/*
 * Copyright (c) 2005-2007, The haXe Project Contributors
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
// Originally haxe.xml.Check
// Extended by Marcus Bergstrom @ Quickform
// Adding optional attribute.
// Adding RAnyContent that will ignore any children.

enum Filter {
	FInt;
	FBool;
	FEnum( values : Array<String> );
	FReg( matcher : EReg );
}

enum Attrib {
	OptionalAtt( name : String, ?filter : Filter);
	Att( name : String, ?filter : Filter, ?defvalue : String );
}

enum Rule {
	RNode( name : String, ?attribs : Array<Attrib>, ?childs : Rule );
	RData( ?filter : Filter );
	RMulti( rule : Rule, ?atLeastOne : Bool );
	RList( rules : Array<Rule>, ?ordered : Bool );
	RChoice( choices : Array<Rule> );
	ROptional( rule : Rule );
	RAnyContent;
}

private enum CheckResult {
	CMatch;
	CMissing( r : Rule );
	CExtra( x : Xml );
	CElementExpected( name : String, x : Xml );
	CDataExpected( x : Xml );
	CExtraAttrib( att : String, x : Xml );
	CMissingAttrib( att : String, x : Xml );
	CInvalidAttrib( att : String, x : Xml, f : Filter );
	CInvalidData( x : Xml, f : Filter );
	CInElement( x : Xml, r : CheckResult );
}

class XMLCheck {

	static var blanks = ~/^[ \r\n\t]*$/;

	static function isBlank( x : Xml ) {
		return( x.nodeType == Xml.PCData && blanks.match(x.nodeValue) ) || x.nodeType == Xml.Comment;
	}

	static function filterMatch( s : String, f : Filter ) {
		switch( f ) {
		case FInt: return filterMatch(s,FReg(~/[0-9]+/));
		case FBool: return filterMatch(s,FEnum(["true","false","0","1"]));
		case FEnum(values):
			for( v in values )
				if( s == v )
					return true;
			return false;
		case FReg(r):
			return r.match(s);
		}
	}

	static function isNullable( r : Rule ) {
		switch( r ) {
		case RMulti(r,one):
			return( one != true || isNullable(r) );
		case RList(rl,_):
			for( r in rl )
				if( !isNullable(r) )
					return false;
			return true;
		case RChoice(rl):
			for( r in rl )
				if( isNullable(r) )
					return true;
			return false;
		case RData(_):
			return false;
		case RNode(_,_,_):
			return false;
		case ROptional(_):
			return true;
		case RAnyContent:
			return true;
		}
	}

	static function check( x : Xml, r : Rule ) {
		switch( r ) {
		// check the node validity
		case RNode(name,attribs,childs):
			if( x.nodeType != Xml.Element || x.nodeName != name )
				return CElementExpected(name,x);
			var attribs = if( attribs == null ) new Array() else attribs.copy();
			// check defined attributes
			for( xatt in x.attributes() ) {
				var found = false;
				for( att in attribs )
					switch( att ) {
					case Att(name,filter,defvalue):
						if( xatt != name )
							continue;
						if( filter != null && !filterMatch(x.get(xatt),filter) )
							return CInvalidAttrib(name,x,filter);
						attribs.remove(att);
						found = true;
					case OptionalAtt(name,filter):
						if (xatt != name)
							continue;
						if ( filter != null && !filterMatch(x.get(xatt), filter) ) {
							return CInvalidAttrib(name, x, filter);
						}
						attribs.remove(att);
						found = true;
					}
				if( !found )
					return CExtraAttrib(xatt,x);
			}
			// check remaining unchecked attributes
			for( att in attribs )
				switch( att ) {
				case Att(name,_,defvalue):
					if( defvalue == null )
						return CMissingAttrib(name,x);
				default:				
				}
			// check childs
			if( childs == null )
				childs = RList([]);
			var m = checkList(x.iterator(),childs);
			if( m != CMatch )
				return CInElement(x,m);
			// set default attribs values
			for( att in attribs )
				switch( att ) {
				case Att(name,_,defvalue):
					x.set(name,defvalue);
				default:
				}
			return CMatch;
		// check the data validity
		case RData(filter):
			if( x.nodeType != Xml.PCData && x.nodeType != Xml.CData )
				return CDataExpected(x);
			if( filter != null && !filterMatch(x.nodeValue,filter) )
				return CInvalidData(x,filter);
			return CMatch;
		// several choices
		case RChoice(choices):
			if( choices.length == 0 )
				throw "No choice possible";
			for( c in choices )
				if( check(x,c) == CMatch )
					return CMatch;
			return check(x,choices[0]);
		case ROptional(r):
			return check(x,r);
		case RAnyContent:
			return CMatch;
		default:
			throw "Unexpected "+Std.string(r);
		}
	}

	static function checkList( it : Iterator<Xml>, r : Rule ) {
		switch( r ) {
		case RList(rules,ordered):
			var rules = rules.copy();
			for( x in it ) {
				if( isBlank(x) )
					continue;
				var found = false;
				for( r in rules ) {
					var m = checkList([x].iterator(),r);
					if( m == CMatch ) {
						found = true;
						switch(r) {
						case RMulti(rsub,one):
							if( one ) {
								var i;
								for( i in 0...rules.length )
									if( rules[i] == r )
										rules[i] = RMulti(rsub);
							}
						default:
							rules.remove(r);
						}
						break;
					} else if( ordered && !isNullable(r) ) {
						return m;
					} else switch(m) {
						// ADDED BY MB! Not sure why this is not reporting properly.
						case CInvalidAttrib(att, x, f): 
							return m;
						case CExtraAttrib(xatt, x):
							return m;
						default:
					}
				}
				if( !found ) {
					return CExtra(x);
				}
			}
			for( r in rules )
				if( !isNullable(r) )
					return CMissing(r);
			return CMatch;
		case RMulti(r,one):
			var found = false;
			for( x in it ) {
				if( isBlank(x) )
					continue;
				var m = checkList([x].iterator(),r);
				if( m != CMatch )
					return m;
				found = true;
			}
			if( one && !found )
				return CMissing(r);
			return CMatch;
		case RAnyContent:
			return CMatch;
		default:
			var found = false;
			for( x in it ) {
				if( isBlank(x) )
					continue;
				var m = check(x,r);
				if( m != CMatch )
					return m;
				found = true;
				break;
			}
			if( !found ) {
				switch(r) {
				case ROptional(_):
				default: return CMissing(r);
				}
			}
			for( x in it ) {
				if( isBlank(x) )
					continue;
				return CExtra(x);
			}
			return CMatch;
		}
	}

	static function makeWhere( path : Array<Xml> ) {
		if( path.length == 0 )
			return "";
		var s = "In ";
		var first = true;
		for( x in path ) {
			if( first )
				first = false;
			else
				s += ".";
			s += x.nodeName;
		}
		return s+": ";
	}

	static function makeString( x : Xml ) {
		if( x.nodeType == Xml.Element )
			return "element "+x.nodeName;
		var s = x.nodeValue.split("\r").join("\\r").split("\n").join("\\n").split("\t").join("\\t");
		if( s.length > 20 )
			return s.substr(0,17)+"...";
		return s;
	}

	static function makeRule( r : Rule ) {
		switch( r ) {
		case RNode(name,_,_): return "element "+name;
		case RData(_): return "data";
		case RMulti(r,_): return makeRule(r);
		case RList(rules,_): return makeRule(rules[0]);
		case RChoice(choices): return makeRule(choices[0]);
		case ROptional(r): return makeRule(r);
		case RAnyContent: return "";
		}
	}

	static function makeError(m,?path) {
		if( path == null )
			path = new Array();

		switch( m ) {
		case CMatch: throw "assert";
		case CMissing(r):
			return makeWhere(path)+"Missing "+makeRule(r);
		case CExtra(x):
			return makeWhere(path)+"Unexpected "+makeString(x);
		case CElementExpected(name,x):
			return makeWhere(path)+makeString(x)+" while expected element "+name;
		case CDataExpected(x):
			return makeWhere(path)+makeString(x)+" while data expected";
		case CExtraAttrib(att,x):
			path.push(x);
			return makeWhere(path)+"unexpected attribute "+att;
		case CMissingAttrib(att,x):
			path.push(x);
			return makeWhere(path)+"missing required attribute "+att;
		case CInvalidAttrib(att,x,f):
			path.push(x);
			return makeWhere(path)+"invalid attribute value for "+att;
		case CInvalidData(x,f):
			return makeWhere(path)+"invalid data format for "+makeString(x);
		case CInElement(x,m):
			path.push(x);
			return makeError(m,path);
		}
	}

	public static function checkNode( x : Xml, r : Rule ) {
		var m = checkList([x].iterator(),r);
		if( m == CMatch )
			return;
		throw makeError(m);
	}

	public static function checkDocument( x : Xml, r : Rule ) {
		if( x.nodeType != Xml.Document )
			throw "Document expected";
		checkNode(x.firstElement(), r);
	}

}