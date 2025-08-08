This is the item system for my upcoming game "Salt VS Pepper" on Steam.

It's made for adding new items such as guns (shootable) and walls (placeable) very easy.

You add a new item ("X") to the Items enumerator, and create a new class ("ItemX") that inherits the default Item class, and only change the necessary parts.

By default, it automatically handles "shootable" and "placeable" items' functions without changing anything else.

And then its constructor is added to the global gItemData array for easy access.
