function Node(north, west, south, east) {
	this.north = north;
	this.west = west;
	this.south = south;
	this.east = east;
}

function Mapping() {
	this.hub = new Node(null, null, null, null);
}

Mapping.prototype.analyze = function(dirList) {
	var current = this.hub;
	for (var i = 0; i < dirList.length; i++) {
		switch (dirList[i]) {
			case 1:
				if (current.north == null) {
					current.north = new Node(null, null, current, null);
				}
				current = current.north;
				break;
			case 2:
				if (current.west == null) {
					current.west = new Node(null, null, null, current);
				}
				current = current.west;
				break;
			case 3:
				if (current.south == null) {
					current.south = new Node(current, null, null, null);
				}
				current = current.south;
				break;
			case 4:
				if (current.east == null) {
					current.east = new Node(null, current, null, null);
				}
				current = current.east;
				break;
			default:
				console.log("No direction at all?");
				break;
		}
	}
}

module.exports = Mapping;

