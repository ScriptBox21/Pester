﻿Set-StrictMode -Version Latest

InPesterModuleScope {
    Describe 'Get-ShouldOperator' {
        Context 'Overview' {

            BeforeAll {
                # $AssertionOperators is a private Pester variable. Requires InModuleScope
                $OpCount = $AssertionOperators.Count

                $get1 = Get-ShouldOperator
                Add-ShouldOperator -Name 'test' -Test { 'test' }
                $get2 = Get-ShouldOperator
            }

            It 'Returns all registered operators' {
                $get1.Count | Should -Be $OpCount
                $get2.Count | Should -Be ($OpCount + 1)
            }

            It 'Returns Name and Alias properties' {
                $get1[0].PSObject.Properties |
                    Select-Object -ExpandProperty Name |
                    Sort-Object |
                    Should -Be 'Alias', 'Name'
            }

            AfterAll {
                $null = $AssertionOperators.Remove("test")
            }
        }

        Context 'Name parameter' {
            BeforeAll {
                $BGT = Get-ShouldOperator -Name BeGreaterThan
            }

            It 'Should return a help examples object' {
                # BeOfType doesn't work here. PowerShell's help system is weird
                ($BGT | Get-Member)[0].TypeName | Should -BeExactly 'MamlCommandHelpInfo#ExamplesView'
            }

            It 'Returns help for all internal Pester assertion operators' {
                $AssertionOperators.Keys | Where-Object { $_ -ne 'test' } | ForEach-Object {
                    Get-ShouldOperator -Name $_ | Should -Not -BeNullOrEmpty -Because "$_ should have help"
                }
            }
            It 'Throws on invalid assertion-name' {
                { Get-ShouldOperator BeHorrible } | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -ErrorId 'ParameterArgumentValidationError,Get-ShouldOperator' -ExpectedMessage "*on parameter 'Name'*does not belong to the set*"
            }

            It 'Supports positional value' {
                { Get-ShouldOperator Be } | Should -Not -Throw -ErrorId 'PositionalParameterNotFound,Get-ShouldOperators' -Because 'Name-parameter supports values at position 0'
            }
        }
    }
}
