# Python Scripts

## Guild Food Alert - `guild_low_food_alert.py`  
Sends a Discord post if the guild storage is running low on certain foods.
### Configuration
Replace the `GUILD_ID`, `API_KEY` and `DISCORD_WEBHOOK_URL`.  
Change `ITEM_THRESHOLD` to whatever value you prefer. Any items at or below this value will get posted to Discord.  
You can add / change / remove items in the `items_to_check` list.  
These are the items that will be checked, and if any are below the item threshold, a message will be posted on Discord.
