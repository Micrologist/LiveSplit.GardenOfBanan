state("Garden Of Banan"){}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.LoadSceneManager = true;
}

init
{
    current.scene = "";
    old.scene = "";
    vars.EndingsFound = false;
    vars.ending1ObjectPtr = IntPtr.Zero;
    vars.ending2ObjectPtr = IntPtr.Zero;
}

update
{
    if(!String.IsNullOrEmpty(vars.Helper.Scenes.Active.Name))
        current.scene = vars.Helper.Scenes.Active.Name;

    if(timer.CurrentPhase == TimerPhase.Running && !vars.EndingsFound)
    {
        var lastObjectTransformPtr = IntPtr.Zero;
        new DeepPointer(vars.Helper.Scenes.Active.Address + 0xB0, 0x10, 0x0).DerefOffsets(game, out lastObjectTransformPtr);
        var lastObjectName = new DeepPointer(lastObjectTransformPtr + 0x30, 0x60, 0x0).DerefString(game, 255);
        
        if(lastObjectName == "Canvas")
        {
            print("Endings found");
            IntPtr objPtr = IntPtr.Zero;
            new DeepPointer(lastObjectTransformPtr + 0x70, 0x8 * 0x8, 0x30, 0x0).DerefOffsets(game, out objPtr);
            vars.ending1ObjectPtr = objPtr;
            new DeepPointer(lastObjectTransformPtr + 0x70, 0x7 * 0x8, 0x30, 0x0).DerefOffsets(game, out objPtr);
            vars.ending2ObjectPtr = objPtr;
            vars.EndingsFound = true;
        }
    }

    current.ending1active = vars.EndingsFound ? game.ReadValue<bool>((IntPtr)vars.ending1ObjectPtr + 0x56) : false;
    current.ending2active = vars.EndingsFound ? game.ReadValue<bool>((IntPtr)vars.ending2ObjectPtr + 0x56) : false;
}

start
{
    return current.scene == "SampleScene" && old.scene == "Opening Cutscene";
}

onStart
{
    vars.EndingsFound = false;
    vars.ending1ObjectPtr = IntPtr.Zero;
    vars.ending2ObjectPtr = IntPtr.Zero;
}

split
{
    return (current.ending1active && !old.ending1active) || (current.ending2active && !old.ending2active);
}

reset
{
    return current.scene == "Start Screen";
}