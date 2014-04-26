utils = require('../utils');
node = require('../node');

describe("the `node` module", function() {
	it("provides tree walking functionality to the package", function() {
		describe("Node", function() {
			var n;

			it("is the `Node` base class", function() {
				n = new node.Node(1);
				expect(n).toEqual(jasmine.any(node.Node));
			});
			
			it("has one property, `next`", function() {
				expect(n.next).toBe(1);
			});

			it("has one method, `copy`", function() {
				n.meta = [1, 2, 3];
				var copy = n.copy();

				expect(Object.keys(n)).toEqual(Object.keys(copy));

				copy.meta[0] = 4;
				expect(n.meta).not.toEqual(copy.meta);
			});
		});

		describe("Tree", function() {
			var t, n;

			n = new node.Node(1);
			m = new node.Node(n);

			it("is the `Tree` base class", function() {
				t = new node.Tree(m);
				expect(t).toEqual(jasmine.any(node.Tree));
			});

			it("has two properties (noninherited)", function() {
				expect(t.root).toEqual(t.node);
			});

			it("has one method, `next`", function() {
				var t2 = t.next();
				expect(t2).toEqual(t);
				expect(t2.root).not.toEqual(t2.node);
				expect(t2.root.next).toEqual(t2.node);
			});
		});
	});
});