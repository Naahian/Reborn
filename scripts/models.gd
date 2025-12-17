extends Node

class Item:
	var type: String
	var img: Texture
	var price: int
	var value: int

	func _init(_type: String, _img: Texture, _price: int, _value: int):
		type = _type
		img = _img
		price = _price
		value = _value
		
	func duplicate() -> Item:
		return Item.new(type, img, price, value)


func to_shopItem(item: Item, slot:Node2D) -> Node:
	slot.get_node("image").texture = item.img
	slot.get_node("price/text").text = str(item.price)
	return slot


func to_inventoryItem(item: Item, slot:Node2D) -> Node:
	slot.get_node("image").texture = item.img
	return slot
