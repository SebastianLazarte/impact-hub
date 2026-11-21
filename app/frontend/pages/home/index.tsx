import { Head } from '@inertiajs/react'

type Estimate<T> = { value: T | null; reason: string | null }

type Step = {
  name: string
  department: string
  input_type: 'structured' | 'semi' | 'unstructured'
  rule_clarity: 'clear' | 'partial' | 'judgement'
  sensitive_data: boolean
  hours: Estimate<string>
  score: Estimate<number>
  method: 'rules' | 'ai_assisted' | 'human'
  control: 'none' | 'review' | 'approve'
}

const CONTROL_STYLE: Record<Step['control'], string> = {
  none: 'bg-emerald-100 text-emerald-800',
  review: 'bg-amber-100 text-amber-800',
  approve: 'bg-rose-100 text-rose-800',
}

function EstimateCell<T>({ estimate, suffix = '' }: { estimate: Estimate<T>; suffix?: string }) {
  if (estimate.value === null) {
    return <span className="text-slate-400" title={estimate.reason ?? ''}>unknown</span>
  }
  return <span className="tabular-nums">{String(estimate.value)}{suffix}</span>
}

export default function Home({ steps }: { steps: Step[] }) {
  return (
    <>
      <Head title="Intake Hub" />
      <main className="mx-auto max-w-5xl px-4 py-10">
        <h1 className="text-2xl font-semibold text-slate-900">Intake Hub</h1>
        <p className="mt-2 max-w-2xl text-slate-600">
          Rules compute every number. The LLM only interprets text, may raise a human
          control but never lower it, and a person approves every item.
        </p>

        <div className="mt-8 overflow-x-auto rounded-lg border border-slate-200">
          <table className="min-w-full divide-y divide-slate-200 text-sm">
            <thead className="bg-slate-50 text-left text-slate-600">
              <tr>
                <th className="px-4 py-3 font-medium">Step</th>
                <th className="px-4 py-3 font-medium">Department</th>
                <th className="px-4 py-3 text-right font-medium">Hours / month</th>
                <th className="px-4 py-3 text-right font-medium">Score</th>
                <th className="px-4 py-3 font-medium">Method</th>
                <th className="px-4 py-3 font-medium">Control</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 bg-white">
              {steps.map((step) => (
                <tr key={step.name}>
                  <td className="px-4 py-3 text-slate-900">
                    {step.name}
                    {step.sensitive_data && (
                      <span className="ml-2 rounded bg-slate-100 px-1.5 py-0.5 text-xs text-slate-600">sensitive</span>
                    )}
                  </td>
                  <td className="px-4 py-3 text-slate-600">{step.department}</td>
                  <td className="px-4 py-3 text-right"><EstimateCell estimate={step.hours} /></td>
                  <td className="px-4 py-3 text-right"><EstimateCell estimate={step.score} /></td>
                  <td className="px-4 py-3 text-slate-600">{step.method.replace('_', ' ')}</td>
                  <td className="px-4 py-3">
                    <span className={`rounded px-2 py-0.5 text-xs font-medium ${CONTROL_STYLE[step.control]}`}>
                      {step.control}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </main>
    </>
  )
}
