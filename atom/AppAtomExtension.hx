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

package atom;
import atom.Atom;
import atom.AtomValidator;

class AppAtomExtension implements IAtomExtension {
	
	public static inline var NS:AtomNS = {uri: "http://www.w3.org/2007/app", localName: "app" };
	public var categoriesLink(default,setCategoriesLink):String;
	public var draft(default,setDraft):Null<Bool>;
	public var edited(default,setEdited):AtomDate;
	
	public function new() {
	}
	
	public function getNamespace():AtomNS {
		return NS;
	}
		
	public function extend(xml:Xml, addPrologsAndNamespaces:Bool=true):Void {
		if (categoriesLink != null && categoriesLink != "") {
			var categoriesElement = Xml.createElement("app:categories");
			categoriesElement.set("href", categoriesLink);
			xml.addChild(categoriesElement);
		}
		if (draft != null) {
			var controlElement = Xml.createElement("app:control");
			var draftElement = Xml.createElement("app:draft");
			draftElement.addChild(Xml.createPCData(draft ? "yes" : "no"));
			controlElement.addChild(draftElement);
			xml.addChild(controlElement);
		}
		if (edited != null) {
			var x_edited = Xml.createElement("app:edited");
			x_edited.addChild(Xml.createPCData(edited.toString()));
			xml.addChild(x_edited);
		}
	}
	
	public function toXMLString(buf:StringBuf, addPrologsAndNamespaces:Bool=true):Void {
		if (categoriesLink != null && categoriesLink != "") {
			buf.add('<app:categories href="'+categoriesLink+'">');
		}
		if (draft != null) {
			buf.add('<app:control>');
			buf.add('<app:draft>');
			buf.add(draft ? "yes" : "no");
			buf.add("</app:draft>");
			buf.add("</app:control>");
		}
		if (edited != null) {
			buf.add("<app:edited>");
			buf.add(edited.toString());
			buf.add("</app:edited>");
		}		
	}
	
	public function setCategoriesLink(href:String):String {
		categoriesLink = href;
		return categoriesLink;
	}
	
	public function setDraft(b:Bool):Bool {
		draft = b;
		return draft;
	}
	public function setEdited(atomDate:AtomDate):AtomDate {
		edited = atomDate;
		return edited;
	}
	
	// AtomValidator methods.
	public static function getNamespaceRuleAsDefault():Attrib {
		return Attrib.Att("xmlns", FEnum(["http://www.w3.org/2007/app"]));
	}
	public static function getNamespaceRule():Attrib {
		return Attrib.Att("xmlns:app", FEnum(["http://www.w3.org/2007/app"]));
	}
	public static function getFeedRules():Array<Rule> {
		/*
			TODO app:collection may appear as a child on an atom:feed or atom:source element in an Atom Feed Document.
			Resource: AtomEnabled - The Atom Publising Protocol §8.3.5
		*/
		return [
		];
	}
	public static function getEntryRules():Array<Rule> {
		return [
			// edited
			ROptional(RNode("app:edited", [], AtomValidator.getAtomDateRule())),
			// control
			ROptional(RNode("app:control", [], 
				// draft.
				ROptional(RNode("app:draft", [], RData(FEnum(["yes","no"]))))
			))
			/*
				TODO Check for edit links. etc.
			*/
		];
	}
	
}