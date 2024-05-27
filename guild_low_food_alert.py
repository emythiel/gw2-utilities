# Import requests and json
import requests
import json

# Configuration
GUILD_ID = 'your_guild_id'
API_KEY = 'your_api_key'
DISCORD_WEBHOOK_URL = 'your_discord_webhook_url'
ITEM_THRESHOLD = 15

# Array of objects of items to check
items_to_check = [
    {
        "id": 1078,
        "name": "Bowl of Fruit Salad with Mint Garnish",
        "link": "https://wiki.guildwars2.com/wiki/Bowl_of_Fruit_Salad_with_Mint_Garnish",
        "icon": "https://wiki.guildwars2.com/images/4/47/Bowl_of_Fruit_Salad_with_Mint_Garnish.png"
    },
    {
        "id": 1106,
        "name": "Peppered Cured Meat Flatbread",
        "link": "https://wiki.guildwars2.com/wiki/Peppered_Cured_Meat_Flatbread",
        "icon": "https://wiki.guildwars2.com/images/2/2d/Peppered_Cured_Meat_Flatbread.png"
    },
    {
        "id": 1094,
        "name": "Peppercorn-Crusted Sous-Vide Steak",
        "link": "https://wiki.guildwars2.com/wiki/Peppercorn-Crusted_Sous-Vide_Steak",
        "icon": "https://wiki.guildwars2.com/images/2/2e/Peppercorn-Crusted_Sous-Vide_Steak.png"
    },
]

# GET API request
def get_guild_storage():
    url = f'https://api.guildwars2.com/v2/guild/{GUILD_ID}/storage?access_token={API_KEY}'
    response = requests.get(url)
    response.raise_for_status()
    return response.json()

# Post to Discord Webhook
def post_to_discord(embeds):
    payload = {
        "content": "The following food is running low in the guild storage!",
        "embeds": embeds,
        "attachments": []
    }
    response = requests.post(DISCORD_WEBHOOK_URL, json=payload)
    response.raise_for_status()

def main():
    storage_data = get_guild_storage()
    embeds = []

    for item in items_to_check:
        for storage_item in storage_data:
            if storage_item['id'] == item['id'] and storage_item['count'] <= ITEM_THRESHOLD:
                embed = {
                    "title": item['name'],
                    "url": item['link'],
                    "color": None,
                    "fields": [
                        {
                            "name": "Remaining",
                            "value": str(storage_item['count'])
                        }
                    ],
                    "thumbnail": {
                        "url": item['icon']
                    }
                }
                embeds.append(embed)
    if embeds:
        post_to_discord(embeds)

if __name__ == "__main__":
    main()
