<script lang="ts">
  let {
    label,
    score
  }: {
    label: string;
    score: number;
  } = $props();
</script>

<div class="score-bar">
  <div class="score-bar__row">
    <span>{label}</span>
    <strong>{score.toFixed(1)}</strong>
  </div>
  <div class="score-bar__track" aria-hidden="true">
    <span class="score-bar__fill" style={`width: ${(score / 10) * 100}%`}></span>
  </div>
</div>
