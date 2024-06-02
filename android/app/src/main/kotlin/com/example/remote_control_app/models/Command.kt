import org.json.JSONObject

data class Command(
    val type: String,
    val startCoords: Pair,
    val endCoords: Pair
)

data class Pair(
    val x: Double,
    val y: Double
)

fun Command.toJson(): JSONObject {
    val jsonObject = JSONObject()
    jsonObject.put("type", type)
    jsonObject.put("startCoords", startCoords.toJson())
    jsonObject.put("endCoords", endCoords.toJson())
    return jsonObject
}

fun Pair.toJson(): JSONObject {
    val jsonObject = JSONObject()
    jsonObject.put("x", x)
    jsonObject.put("y", y)
    return jsonObject
}

fun JSONObject.toCommand(): Command {
    val type = getString("type")
    val startCoords = getJSONObject("startCoords").toPair()
    val endCoords = getJSONObject("endCoords").toPair()
    return Command(type, startCoords, endCoords)
}

fun JSONObject.toPair(): Pair {
    val x = getDouble("x")
    val y = getDouble("y")
    return Pair(x, y)
}

fun main() {
    // Create an instance of Command
    val command = Command("move", Pair(1.0, 2.0), Pair(3.0, 4.0))

    // Serialize to JSON
    val json = command.toJson()
    println("Serialized JSON: $json")

    // Deserialize from JSON
    val deserializedCommand = json.toCommand()
    println("Deserialized Command: $deserializedCommand")
}