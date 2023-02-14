state("Garden Of Banan"){}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.LoadSceneManager = true;
}

init
{
    old.scene = current.scene = "";
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
        var lastObjectTransformPtr = vars.Helper.Deref(vars.Helper.Scenes.Active.Address + 0xB0, 0x10, 0x0);
        var lastObjectName = vars.Helper.ReadString(255, ReadStringType.UTF8, lastObjectTransformPtr + 0x30, 0x60, 0x0);
        
        if(lastObjectName == "Canvas")
        {
            vars.Log("Endings found");
            vars.ending1ObjectPtr = vars.Helper.Deref(lastObjectTransformPtr + 0x70, 0x8 * 0x8, 0x30, 0x0);
            vars.ending2ObjectPtr = vars.Helper.Deref(lastObjectTransformPtr + 0x70, 0x7 * 0x8, 0x30, 0x0);
            vars.EndingsFound = true;
        }
    }

    current.ending1active = vars.EndingsFound && vars.Helper.Read<bool>(vars.ending1ObjectPtr + 0x56);
    current.ending2active = vars.EndingsFound && vars.Helper.Read<bool>(vars.ending2ObjectPtr + 0x56);
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
