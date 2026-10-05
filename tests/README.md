# Regression checks

Run the complete regression suite from the repository root:

```powershell
python -B -m unittest discover -s tests -v
python -B TXHBalance\_tools\validate_txhbalance.py
```

Python and Lua 5.3+ are required. No Python packages or game installation are needed.

The SQLite tests execute the actual production SQL against minimal in-memory
tables. They check the three restored unit updates, Poland's technology/civic
gate, and the granary's database collection. The Lua fixture loads the actual
gameplay and UI scripts, and obtains the modifier amounts and yield types by
executing the actual BCY SQL first. It models current plot yields, persistent
properties, city ownership, capital selection and registered events.
It also checks that Balanced/Maximum founding rewards apply once across duplicate
events and that existing old-save cities are adopted without replaying rewards.

The fixture is an engine-boundary test. It assumes repeatable modifiers stack
and applied effects are visible to the next gameplay operation. It does not
reproduce Firaxis asynchronous yield processing, save serialization, multiplayer
authority or the game's rendering. Those require an in-game check.

The old external review reproductions deliberately retain the original failing
behavior as their expected outcome; they are not the fixed version's test suite.
