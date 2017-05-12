﻿// ---------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// ---------------------------------------------------------------

namespace Microsoft.Azure.Devices.Edge.Util.Test.Common
{
    using System;
    using Xunit.Sdk;

    [TraitDiscoverer("Microsoft.Azure.Devices.Edge.Util.Test.Common.BvtDiscoverer", "Microsoft.Azure.Devices.Edge.Util.Test.Common")]
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
    public class BvtAttribute : Attribute, ITraitAttribute
    {
    }
}