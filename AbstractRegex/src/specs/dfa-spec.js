utils = require('../utils');
node = require('../node');
dfa = require('../dfa');

describe("dfa", function() {
	it("contains regex syntax tree facilities", function() {
		describe("Token", function() {
			var token = new dfa.Token("", {});

			it("is the basic node object of the Deterministic Finite Automata", function() {
				expect(token).toEqual(jasmine.any(dfa.Token));
			});
		});

		describe("Path", function() {
			var A = new dfa.Token("", {}),
				B = new dfa.Token("", {}, A),
				C = new dfa.Token("", {}, B),
				path = new dfa.Path(C);

			it("holds path traversal state", function() {
				expect(path).toEqual(jasmine.any(dfa.Path));
				expect(path.root).toEqual(path.node);
				expect(path.pointer).toBe(0);

				path.advancePointer();
				expect(path.pointer).toBe(1);

				path.consumeToken();
				expect(path.node).toEqual(B);

				path.anonStack.push([0, 1]);
				var copy = path.copy();
				expect(path).toEqual(copy);

				copy.consumeToken();
				expect(copy.node).not.toEqual(path.node);

				copy.anonStack.push([1, 2]);
				expect(copy.anonStack).not.toEqual(path.anonStack);
			});

			it("provides tools to generate capture groups", function() {
				path.reset();
				path.anonStack = [];

				path.beginAnonymousCapture();
				expect(path.anonStack).toEqual([["(", 0]]);
				path.advancePointer();
				path.endAnonymousCapture();
				expect(path.anonStack).toEqual([]);
				expect(path.anonRanges).toEqual([[0, 1]]);
			});

			it("has a method that flushes all capture groups", function() {
				path.reset();
				path.anonStack = [];
				path.anonRanges = [];

				path.beginAnonymousCapture();
				path.beginNamedCapture("saturn");
				path.advancePointer().advancePointer();
				path.flushAllCaptures();

				expect(path.anonStack).toEqual([]);
				expect(path.anonRanges).toEqual([[0, 2]]);
				expect(path.namedStack).toEqual([]);
				expect(path.namedRanges).toEqual({saturn: [0, 2]});
			});
		});

		describe("execute", function() {
			it("executes a tree traversal of a linked-list of regex tokens", function() {
				// TODO: Write the specs for this...
			});
		});
	});
});