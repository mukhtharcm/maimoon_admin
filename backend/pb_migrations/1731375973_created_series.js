/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const collection = new Collection({
    "id": "iebpm9k0j0rkzrg",
    "created": "2024-11-12 01:46:13.977Z",
    "updated": "2024-11-12 01:46:13.977Z",
    "name": "series",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "4lrfqdfp",
        "name": "name",
        "type": "text",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      }
    ],
    "indexes": [],
    "listRule": null,
    "viewRule": null,
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("iebpm9k0j0rkzrg");

  return dao.deleteCollection(collection);
})
