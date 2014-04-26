utils = require('../utils');

describe("utils", function() {
	it("holds some utility functions for the package", function() {

		describe("type", function() {
			it("normalizes type checking", function() {
				expect(utils.type("a")).toBe("String");
				expect(utils.type(1)).toBe("Number");
				expect(utils.type([])).toBe("Array");
				expect(utils.type({})).toBe("Object");
				expect(utils.type(/a/)).toBe("RegExp");
				expect(utils.type(function(){})).toBe("Function");
				expect(utils.type(null)).toBe("null");
				expect(utils.type(undefined)).toBe("undefined");
			});
		});

		describe("extend", function() {
			it("extends objects");
		});

		describe("copyExtend", function() {
			it("extends objects, but makes copies of subobjects and subarrays", function() {
				var orig = {a: [1,2,3], b:{foo: true}},
					copy;

				copy = utils.copyExtend({}, orig);

				expect(orig).toEqual(copy);
				
				copy.a.push(4);

				expect(orig.a).not.toEqual(copy.a);

				copy.b.foo = false;

				expect(orig.b).not.toEqual(copy.b);
			});
		});
	});
});