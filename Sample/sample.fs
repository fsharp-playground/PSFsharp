namespace FsPowerShellSample

open System.Management.Automation

[<Cmdlet("Select", "Max")>]
type SelectMax() = 
    inherit PSCmdlet()
    [<DefaultValue>]
    val mutable private result : int
    [<DefaultValue>]
    val mutable private _InputValue : int
    [<Parameter(Mandatory=false,ValueFromPipeline=true)>]
    member public this.InputValue
        with get() = this._InputValue
        and set value = this._InputValue <- value
    override this.BeginProcessing() =
        do
            this.result <- 0
    override this.ProcessRecord() =
        do
            this.result <- max this.result this._InputValue
    override this.EndProcessing() =
        do
            base.WriteObject(this.result)
