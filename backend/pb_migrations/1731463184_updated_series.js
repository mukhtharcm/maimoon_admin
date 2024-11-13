/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("iebpm9k0j0rkzrg")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "kqmk0ake",
    "name": "image",
    "type": "file",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {
      "mimeTypes": [],
      "thumbs": [],
      "maxSelect": 1,
      "maxSize": 5242880,
      "protected": false
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("iebpm9k0j0rkzrg")

  // remove
  collection.schema.removeField("kqmk0ake")

  return dao.saveCollection(collection)
})
